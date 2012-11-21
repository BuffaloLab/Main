package com.academiken.framegrabm.util;

import com.lti.civil.CaptureStream;
import com.lti.civil.CaptureSystem;
import com.lti.civil.CaptureSystemFactory;
import com.lti.civil.CaptureDeviceInfo;
import com.lti.civil.VideoFormat;
import com.lti.civil.DefaultCaptureSystemFactorySingleton;
import com.lti.civil.CaptureException;
import com.lti.civil.CaptureObserver;
import com.lti.civil.Image;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * GrabCore is the central operations center for initializing, configuring, capturing frames,
 * and shutting down.
 * 
 * @author Kenneth Perrine
 * @Version 0.8 - 06 March 2012
 */
public class GrabCore {
	
	/**
	 * initState is true if GrabCore had been initialized; e.g. if init() was called. 
	 */
	protected boolean initState;
	
	/**
	 * capSystem is the reference to the LTI-Civil capture system.
	 */
	protected CaptureSystem capSystem;
	
	/**
	 * DeviceElem stores device-specific information that is accessed throughout GrabCore.
	 */
	protected class DeviceElem {
		/**
		 * gcDevice describes each possible valid capture device. 
		 */
		protected GrabCoreDevice gcDevice;
		
		/**
		 * formatIndex is the current format index, 0 by default.
		 */
		protected int formatIndex = 1;
		
		/**
		 * capStream is the LTI-Civil stream object for this device, not null if valid and used.
		 */
		protected CaptureStream capStream;
		
		/**
		 * formatList for this device describes each format.
		 */
		protected GrabCoreFormat[] formatList;
		
		/**
		 * formatObjs for this device stores the video format object used by LTI-Civil.
		 */
		protected VideoFormat[] formatObjs;
		
		/**
		 * image is the repository for incoming images from each capture for this device.  If no
		 * image is available (e.g. the device was never told to start capturing), then the image
		 * is null.
		 */
		protected Image image;
		
		/**
		 * operState is true for this device if a capture operation is underway; e.g. if start() was
		 * called.
		 */
		protected boolean operState;
		
		/**
		 * capExc stores the in-capture exception so that on grab it can be rethrown.
		 */
		protected CaptureException capExc;
		
		/**
		 * fillFormatList queries the CaptureStream object for the device's supported video formats.
		 * 
		 * @throws CaptureException
		 */
		protected void fillFormatList() throws CaptureException {
			
			// First, get the CaptureStream object:
			if (capStream == null) {
				capStream = capSystem.openCaptureDeviceStream(gcDevice.deviceID);
			}
			
			// Then, fill the format list:
			List<VideoFormat> formats = capStream.enumVideoFormats();
			formatList = new GrabCoreFormat[formats.size()];
			formatObjs = new VideoFormat[formats.size()];
			int count = 0;
			for (VideoFormat format : formats)
			{
				formatList[count] = new GrabCoreFormat();
				formatList[count].type = formatTypeToString(format.getFormatType());
				formatList[count].width = format.getWidth();
				formatList[count].height = format.getHeight();
				formatList[count].frameRate = format.getFPS();
				formatList[count].description = videoFormatToString(format);
				formatList[count].formatIndex = count + 1;
				formatList[count].deviceIndex = gcDevice.deviceIndex;
				formatObjs[count] = format;
				count++;
			}
		}
	}
	
	/**
	 * deviceElems is allocated so that each element corresponds with each device.
	 */
	protected DeviceElem[] deviceElems;
	
	/**
	 * streamMap maps each CaptureStream object to the respective DeviceElem.  This is needed in the
	 * CaptureObserver routines.
	 */
	protected Map<CaptureStream, DeviceElem> streamMap;
	
	/**
	 * init is the first activity that must be performed in order to get the video capture
	 * working.  If init() is called after already initialized, then shutdown() will automatically
	 * be called first.
	 */
	public synchronized void init() throws CaptureException, FrameGrabMException {
		
		if (initState) {
			shutdown();
		}
		
		// Start up capture system:
		CaptureSystemFactory factory = DefaultCaptureSystemFactorySingleton.instance();
		capSystem = factory.createCaptureSystem();
		capSystem.init();
		
		// Figure out how many devices we have and what they are:
		List list = capSystem.getCaptureDeviceInfoList();
		
		// Did we find any devices?
		if (list.size() <= 0) {
			capSystem.dispose();
			capSystem = null;
			throw new FrameGrabMException("No video capture devices found.");
		}
		
		// Allocate arrays for easy access later:
		deviceElems = new DeviceElem[list.size()];
		streamMap = new HashMap<CaptureStream, DeviceElem>();
		
		// Fill out device list:
		for (int deviceIndex = 0; deviceIndex < list.size(); deviceIndex++)
		{
			deviceElems[deviceIndex] = new DeviceElem();
			
			CaptureDeviceInfo info = (CaptureDeviceInfo)list.get(deviceIndex);
			deviceElems[deviceIndex].gcDevice = new GrabCoreDevice();
			deviceElems[deviceIndex].gcDevice.deviceID = info.getDeviceID();
			deviceElems[deviceIndex].gcDevice.description = info.getDescription();
			deviceElems[deviceIndex].gcDevice.deviceIndex = deviceIndex + 1;
		}
		initState = true;
	}
	
	/**
	 * shutdown terminates all capture activity.  It can be the last method called to perform
	 * a proper deinitialization.
	 */
	public synchronized void shutdown() throws CaptureException, FrameGrabMException {
	
		if (!initState) {
			return;
		}
		for (int deviceIndex = 0; deviceIndex < deviceElems.length; deviceIndex++) {
			if (deviceElems[deviceIndex].capStream != null) {
				if (deviceElems[deviceIndex].operState) {
					stop(deviceIndex + 1);
				}
				deviceElems[deviceIndex].capStream.dispose();
			}
		}
		deviceElems = null;
		if (capSystem != null) {
			capSystem.dispose();
			capSystem = null;
		}
		streamMap = null;
		initState = false;
	}
	
	/**
	 * getDeviceList returns an array of GrabCoreDevice objects that each describe one of
	 * the capture devices.  Use the index value on setDevice() to choose the device to use
	 * with frame captures.
	 */
	public synchronized GrabCoreDevice[] getDeviceList() throws CaptureException, FrameGrabMException {

		if (!initState) {
			init();
		}
		
		// Return a clone of the device list that is maintained by this object:
		GrabCoreDevice[] retList = new GrabCoreDevice[deviceElems.length];
		for (int index = 0; index < deviceElems.length; index++) {
			retList[index] = (GrabCoreDevice)deviceElems[index].gcDevice.clone();
		}
		return retList;
	}
	
	/**
	 * getNumDevices returns the number of capture devices that have been detected.
	 */
	public synchronized int getNumDevices() throws CaptureException, FrameGrabMException {

		if (!initState) {
			init();
		}
		return deviceElems.length;
	}

	/**
	 * getFormatList(int) returns a list of GrabCoreFormat objects that each describe one of the formats
	 * supported by the given device.
	 * 
	 * @param deviceIndex The device index to retrieve the formats on.
	 */
	public synchronized GrabCoreFormat[] getFormatList(int deviceIndex) throws FrameGrabMException, CaptureException {

		if (!initState) {
			init();
		}
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		deviceIndex--;
		if (deviceElems[deviceIndex].formatList == null) {
			deviceElems[deviceIndex].fillFormatList();
		}

		// Return a clone of the device list that is maintained by this object:
		GrabCoreFormat[] retList = new GrabCoreFormat[deviceElems[deviceIndex].formatList.length];
		for (int formatIndex = 0; formatIndex < retList.length; formatIndex++) {
			retList[formatIndex] = (GrabCoreFormat)deviceElems[deviceIndex].formatList[formatIndex].clone();
		}
		return retList;
	}
		
	/**
	 * getFormat(int) returns the current format index for the given device index.
	 */
	public synchronized int getFormat(int deviceIndex) throws FrameGrabMException, CaptureException {

		if (!initState) {
			init();
		}		
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		return deviceElems[deviceIndex - 1].formatIndex;
	}
	
	/**
	 * setFormat sets the desired format on the given device that will be returned when calling grab().
	 */
	public synchronized void setFormat(int deviceIndex, int formatIndex) throws FrameGrabMException, CaptureException {

		if (!initState) {
			init();
		}		
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		deviceIndex--;

		// Stop a capture-in-progress if we are changing the format:
		if ((formatIndex != deviceElems[deviceIndex].formatIndex) && deviceElems[deviceIndex].operState) {
			stop(deviceIndex + 1);
			deviceElems[deviceIndex].image = null;
			deviceElems[deviceIndex].capExc = null;

			// To avert a crash, dispose of the old capStream object.
			deviceElems[deviceIndex].capStream.dispose();
			deviceElems[deviceIndex].capStream = null;
		}
				
		// Refresh capture stream object and get valid formats:
		if (deviceElems[deviceIndex].capStream == null) {
			deviceElems[deviceIndex].fillFormatList();
		}
	
		if ((formatIndex < 1) || (formatIndex > deviceElems[deviceIndex].formatList.length)) {
			throw new FrameGrabMException("Format index " + formatIndex + " is outside valid range.");
		}
		
		// Set the format index we'll use for captures:
		deviceElems[deviceIndex].formatIndex = formatIndex;
	}
	
	/**
	 * getInitState returns the state of GrabCore.  That is, false if this hasn't been initialized,
	 * (or shutdown() was called), and true if this is initialized.
	 */
	public synchronized boolean getState() {
		
		return initState;
	}
	
	/**
	 * getOperState returns true if a capture operation is underway for the given device index; e.g. if
	 * start() had been called.
	 */
	public synchronized boolean getOperState(int deviceIndex) throws FrameGrabMException, CaptureException {

		if (!initState) {
			init();
		}		
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		return deviceElems[deviceIndex - 1].operState;
	}
	
	/**
	 * start begins the capture process on the given device.  Frames will continuously be captured, but will
	 * not be available until grab() is called.  Start clears out the most recent image that was captured.
	 */
	public synchronized void start(int deviceIndex) throws FrameGrabMException, CaptureException {
		
		if (!initState) {
			init();
		}
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		deviceIndex--;
		deviceElems[deviceIndex].image = null;
		deviceElems[deviceIndex].capExc = null;
		if (deviceElems[deviceIndex].capStream == null) {
			deviceElems[deviceIndex].fillFormatList(); // This initializes capStream.
		}
		deviceElems[deviceIndex].capStream.setObserver(new CapObserver());
		streamMap.put(deviceElems[deviceIndex].capStream, deviceElems[deviceIndex]);
		if (!deviceElems[deviceIndex].operState) {
			deviceElems[deviceIndex].capStream
				.setVideoFormat(deviceElems[deviceIndex].formatObjs[deviceElems[deviceIndex].formatIndex - 1]);
			deviceElems[deviceIndex].capStream.start();
		}
		deviceElems[deviceIndex].operState = true;
	}
	
	/**
	 * stop ends the capture process.  Whatever frame that had recently been grabbed is available after 
	 * stopping.  The format may be changed and the capture may be restarted.
	 */
	public synchronized void stop(int deviceIndex) throws FrameGrabMException, CaptureException {
		
		if (!initState) {
			init();
		}
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		deviceIndex--;
		if (deviceElems[deviceIndex].operState) {
			deviceElems[deviceIndex].capStream.stop();
			deviceElems[deviceIndex].operState = false;
		}
	}
	
	/**
	 * isFramePending returns true if there is a frame or exception waiting for when grab() is called.
	 * Otherwise, grab() will block until a frame is ready or a capture exception is thrown.
	 */
	public synchronized boolean isFramePending(int deviceIndex) throws FrameGrabMException, CaptureException {
		
		if (!initState) {
			init();
		}
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		deviceIndex--;
		return (deviceElems[deviceIndex].capExc != null) || (deviceElems[deviceIndex].image != null);
	}
	
	/**
	 * grab returns the most recent captured frame, or throws an exception if there was a capture exception.
	 * If a capture process had been started, grab will block until one of these events happens.  If a block
	 * is interrupted or no capture process is engaged, and nothing is pending, then null is returned.
	 * Use isFramePending() to check whether there is a frame pending to prevent unnecessary blocking.
	 */
	public synchronized byte[] grab(int deviceIndex) throws FrameGrabMException, CaptureException {
		
		if (!initState) {
			init();
		}
		if ((deviceIndex < 1) || (deviceIndex > deviceElems.length)) {
			throw new FrameGrabMException("Device index " + deviceIndex + " is outside valid range.");
		}
		deviceIndex--;
		
		// This loop implements the blocking.
		while (true) {			
			// Is there a capture exception pending from the most recent operation?  Throw it.
			if (deviceElems[deviceIndex].capExc != null) {
				CaptureException exc = deviceElems[deviceIndex].capExc;
				deviceElems[deviceIndex].capExc = null;
				throw(exc);
			}
			
			// Is there an image waiting?
			if (deviceElems[deviceIndex].image != null) {
				Image image = deviceElems[deviceIndex].image;
				deviceElems[deviceIndex].image = null;
				return image.getBytes();
			}
			
			// Are we capturing right now?
			if (!deviceElems[deviceIndex].operState) {
				return null;
			}
			
			// Otherwise, nothing happened yet.  Wait.
			try {
				wait();
			}
			catch (InterruptedException exc) {
				return null;
			}
		}
	}
		
	/**
	 * videoFormatToString is borrowed from LTI-Civil CaptureSystemTest.java.
	 */
	private static String videoFormatToString(VideoFormat format) {
		
		return "Type=" + formatTypeToString(format.getFormatType()) + " Width=" + format.getWidth()
			+ " Height=" + format.getHeight() + " FPS=" + format.getFPS(); 
	}

	/**
	 * formatTypeToString is borrowed from LTI-Civil CaptureSystemTest.java.
	 */
	private static String formatTypeToString(int type) {
		
		switch (type) {
			case VideoFormat.RGB24:
				return "RGB24";
			case VideoFormat.RGB32:
				return "RGB32";
			default:
				return "" + type + " (unknown)";
		}
	}

	/**
	 * CapObserver is a protected class inside GrabCore to fulfill the CaptureObserver interface,
	 * but also to prevent public methods from appearing on the outside of CapObserver that shouldn't
	 * be called by MATLAB scripts. 
	 */
	protected class CapObserver implements CaptureObserver {
		/**
		 * onCapError fulfills the CaptureObserver interface, and evidently is called 
		 * when there is a capture error.  The exception will be rethrown when grab() is called.
		 * 
		 * @param sender The capture stream that is associated with this call.
		 * @param exc The exception that was triggered.
		 */
		public void onError(CaptureStream sender, CaptureException exc) {
			
			// Call the method in GrabCore because we need GrabCore's mutex.
			onCapError(sender, exc);
		}

		/**
		 * onCapNewImage is called by CapObserver, and is called whenever a new frame is
		 * captured.
		 * 
		 * @param sender The capture stream that is associated with this call.
		 * @param exc The exception that was triggered.
		 */
		public void onNewImage(CaptureStream sender, Image image) {
			
			// Call the method in GrabCore because we need GrabCore's mutex.
			onCapNewImage(sender, image);
		}
	}
	
	/**
	 * onCapError is called by CapObserver, and evidently is called when there is a capture
	 * error.  The exception will be rethrown when grab() is called.
	 * 
	 * @param sender The capture stream that is associated with this call.
	 * @param exc The exception that was triggered.
	 */
	protected synchronized void onCapError(CaptureStream sender, CaptureException exc) {
		
		DeviceElem deviceElem = streamMap.get(sender);
		if (deviceElem.capExc == null) {
			deviceElem.capExc = exc;
			deviceElem.image = null;
		}
		notify();
	}

	/**
	 * onCapNewImage is called by CapObserver, and is called whenever a new frame is
	 * captured.
	 * 
	 * @param sender The capture stream that is associated with this call.
	 * @param exc The exception that was triggered.
	 */
	protected synchronized void onCapNewImage(CaptureStream sender, Image image) {
		
		DeviceElem deviceElem = streamMap.get(sender);
		deviceElem.image = image;
		deviceElem.capExc = null;
		notify();
	}
}
