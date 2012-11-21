package com.academiken.framegrabm.util;

/**
 * GrabCoreFormat is a format, or capability, that is returned by the LTI-Civil VideoFormat object.
 * Each device will produce one or more formats, and the format can be selected with GrabCore.setFormat()
 * before acquiring video frames.  (It is also important to call GrabCore.setDevice() before calling
 * GrabCore.setFormat()).
 * 
 * @author Kenneth Perrine
 * @Version 0.8 - 06 March 2012
 */
public class GrabCoreFormat implements Cloneable {

	/**
	 * description is a friendly, displayable string that describes the format.
	 */
	public String description;
	
	/**
	 * type is the color format.  The only one that has been tested is "RGB24".
	 */
	public String type;
	
	/**
	 * width is the width of the frame for this format in pixels.
	 */
	public int width;
	
	/**
	 * height is the height of the frame in pixels.
	 */
	public int height;
	
	/**
	 * frameRate is the number of frames per second (FPS) that the device operates at for this format.
	 * Note that since the current feature of FrameGrabM is to grab individual frames, the overhead of
	 * MATLAB may cause the effective frame rate to be considerably less.
	 */
	public float frameRate;
	
	/**
	 * formatIndex is the index of the format that would be used in the GrabCore.setFormat() method.
	 */
	public int formatIndex;
	
	/**
	 * deviceIndex is the index of the device that corresponds with this format.  This is useful if
	 * cell arrays from multiple devices are combined together.
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
