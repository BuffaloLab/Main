package com.academiken.framegrabm.util;

/**
 * FrameGrabMException is used to contain an error that occurs from within the FrameGrabM code.
 * Currently, exceptions that occur from within LTI-Civil are in its own exception class.
 * 
 * @author Kenneth Perrine
 * @Version 0.8 - 06 March 2012
 */
public class FrameGrabMException extends Exception {

	public FrameGrabMException()
	{
		super();
	}

	public FrameGrabMException(String message, Throwable cause)
	{
		super(message, cause);
	}

	public FrameGrabMException(String message)
	{
		super(message);
	}

	public FrameGrabMException(Throwable cause)
	{
		super(cause);
	}
}
