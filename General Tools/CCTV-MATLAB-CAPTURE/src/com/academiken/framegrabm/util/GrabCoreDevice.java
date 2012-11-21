package com.academiken.framegrabm.util;

/**
 * GrabCoreDevice is a return structure from GrabCore.getDevices that contains device information.
 * MATLAB will get a cell array of these, one per detected device.  When configuring GrabCore,
 * one should refer to the information in this class and use the corresponding index with
 * GrabCore.setDevice() to access the desired device.  
 * 
 * @author Kenneth Perrine
 * @Version 0.8 - 06 March 2012
 */
public class GrabCoreDevice implements Cloneable {

	/**
	 * description is the friendly display name for this device.
	 */
	public String description;
	
	/**
	 * deviceID is the device ID returned by the operating system.
	 */
	public String deviceID;
	
	/**
	 * deviceIndex is the value that is used within GrabCore to address this device.
	 */
	public int deviceIndex;
	
	/**
	 * clone allows this object to be copied.
	 */
	public Object clone() {
		try {
			return super.clone();
		}
		catch(CloneNotSupportedException exc) {
			return null;
		}
	}
}
