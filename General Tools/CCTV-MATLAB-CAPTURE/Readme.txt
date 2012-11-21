
do this in matlab:

edit([matlabroot '/toolbox/local/classpath.txt'])
C:/framegrabm/bin
C:/framegrabm/lti-civil-20070920-1721/lti-civil.jar

edit([matlabroot '/toolbox/local/librarypath.txt'])
C:/framegrabm/lti-civil-20070920-1721/native/win32-x86



FrameGrabM: Simple Live Video Camera Frame Grabber Toolkit
Version 0.8 - 10 March 2012
Kenneth Perrine - kperrine@utexas.edu
Requires MATLAB 7.0 (R14) or later for Windows, Mac or Linux

Contents
A.  Introduction
B.  Installation
C.  Uninstallation
D.  Notes for Mac OS X
E.  Directory Structure
F.  Improvements
G.  Function Reference
H.  Samples Reference
--------------------------------------------------------

A.  Introduction

This toolkit provides a quick way to grab still frames from
a live video source, such as a FireWire video camera or a
USB webcam.  Video frames are returned to MATLAB as a matrix
of RGB values.  The toolkit uses LTI-Civil, a Java-based
library instigated by Ken Larson for capturing images (see
http://lti-civil.org/).

Key features of FrameGrabM:
- Targeted for Windows, Mac OS X, and Linux x86 and x64
- No need for MATLAB Image Acquisition Toolbox
- Simultaneous capture from multiple video devices

One the toolkit is installed, capturing frames is easy!
Here is an example MATLAB script for capturing a video frame
from the default capture device:

    fgrabm_start   % Initialize framework & start capture
    pause(2)   % Wait for the capture device to warm up
    pixels = fgrabm_grab();   % Grab the most recent frame
    image(pixels)   % Display the pixels
    fgrabm_shutdown   % Uninitialize the capture framework

Please read the next section for details on installation, as
LTI-CIVIL must be installed, and MATLAB's Java library path
must be configured to refer to LTI-Civil native library
files.  Depending upon how MATLAB was installed, you may
need administrative/root privileges to successfully perform
these changes.  Section D contains information pertaining to
the use of video capture on the Mac OS X platform.

Note that this is a preliminary release and I welcome
feedback that can help lead to a final version.  While this
has been tested in Windows, this has been untested with Mac
OS X and Linux.  Since the underlying LTI-Civil library has
been tested with these platforms, it is anticipated that
there will be few complications in running FrameGrabM since
it is a lightweight layer.  The main challenge is the setup.
If you would like to lend a hand in testing FrameGrabM on
these platforms as well as documenting setup procedures,
please send me an e-mail.  I am also interested in finding
how well this runs in other environments similar to MATLAB
such as Octave.


B.  Installation

To successfully use FrameGrabM, it is necessary to follow
these installation steps:

1. Unpack the FrameGrabM archive into a location on your
   local filesystem.  If you have a place where you use
   other MATLAB add-on functions and toolkits, this is a
   good location for FrameGrabM.

* For reference below, let $FRAMEGRABM be the fully-
specified path to the location where you have placed
FrameGrabM.  Backward or forward slashes will work, or mix
thereof.  An example of a fully-specified path in Windows:
C:\Program Files\MATLAB\R2008b\toolbox\FrameGrabM_0_8

Continuing on:
2. Get the LTI-CIVIL library:
2a. Download the "1721" version of LTI-CIVIL from:
   http://sourceforge.net/projects/lti-civil/files/lti-
   civil/lti-civil-20070920-1721/
2b. Unpack LTI-CIVIL into $FRAMEGRABM, so that LTI-CIVIL's
   files can be accessed at:
   $FRAMEGRABM/lti-civil-20070920-1721

3. Because FrameGrabM accesses Java code for working with
   LTI-Civil, it is necessary to add these to MATLAB's Java
   classpath:
3a. Open the "classpath.txt" file in
   $MATLABROOT/toolbox/local (where $MATLABROOT is the root
   MATLAB directory).  In MATLAB, you can open this file
   for editing by entering at the console prompt:
   edit([matlabroot '/toolbox/local/classpath.txt'])
3b. Add these as new lines (remembering to substitute your
   FrameGrabM path for $FRAMEGRABM):
S:/framegrabm/bin
S:/framegrabm/lti-civil-20070920-1721/lti-civil.jar
   $FRAMEGRABM/bin
   $FRAMEGRABM/lti-civil-20070920-1721/lti-civil.jar
3c. Save classpath.txt and close it.

4. Because of LTI-Civil's dependency on native libraries to
   interface with system-specific video capture libraries,
   it is also necessary to configure MATLAB to access the
   needed resources.
4a. Open the "librarypath.txt" file in
   $MATLABROOT/toolbox/local.  In the MATLAB console, you
   can do:
   edit([matlabroot '/toolbox/local/librarypath.txt'])
4b. Add one of the following paths as a new line
   (remembering to substitute your FrameGrabM path for
   $FRAMEGRABM):
S:/framegrabm/lti-civil-20070920-1721/native/win32-x86
   - For Windows, add $FRAMEGRABM/lti-civil-20070920-
      1721/native/win32-x86
   - For Mac OS X, add $FRAMEGRABM/lti-civil-20070920-
      1721/native/macosx-universal
   - For Linux x86, add $FRAMEGRABM/lti-civil-20070920-
      1721/native/linux-x86
   - For Linux x64, add $FRAMEGRABM/lti-civil-20070920-
      1721/native/linux-amd64
4c. Save librarypath.txt and close it.

5. Finally, you'll need to add the $FRAMEGRABM/matlab
   directory to the MATLAB path.  You can do this by
   accessing the "Set Path..." menu option from the MATLAB
   user interface.  Add $FRAMEGRABM/matlab and save (again,
   remembering to substitute your real path for
   $FRAMEGRABM).

6. Restart MATLAB.

7. Issue at the MATLAB console to test whether FrameGrabM is
   correctly installed: fgrabm_test
   If the installation is correct, you will see a some
   information appear in the console about the default
   capture device and default format output, and a window
   containing an image that was taken from the default
   video device.

If you see exceptions, then the installation was likely not
correct.  Verify what the error pertains to; if it has to do
with the native library, for example, then Step 4 likely
needs to be revisited.  An exception may also be triggered
if the capture device is currently in use by another
application.  If, on the other hand, you see a message
stating that no capture devices were detected, then there
may be compatibility problems with your capture devices.  To
check connections, verify that your capture devices can be
accessed from within other applications.


C.  Uninstallation

To uninstall this package, delete the $FRAMEGRABM directory.
Then, to clean up, review the steps above to determine which
entries need to be removed from respective files.  No other
files will have been created or modified while FrameGrabM
was run.


D.  Notes for Mac OS X

There are reported problems in performing video capture in
Java with OS X Snow Leopard (version 10.6) and presumably
later versions.  For video capture to work, the operating
mode of Java that accesses the QuickTime 7 libraries must be
32 bit.  (The necessary QuickTime 7 libraries are reportedly
installed with QuickTime X).  MATLAB's Java instance can be
configured to run in 32 bit mode by doing this:

1. In MATLAB, find the path where the Java configuration
   file must reside by issuing in the MATLAB console:
   optpath = [matlabroot '/bin/' computer('arch')]
2. Now enter: edit([optpath '/java.opts'])
   If you are asked whether you want to create a new file,
   answer that you do.
3. If the file had already existed and there is a line of
   parameters, you will need to add the new option to the
   end of the line.  Separate the new addition with a
   space.
4. Add the following text if it does not exist already:
   -d32
5. Save java.opts, close it, and then restart MATLAB.

A disadvantage of running Java in 32-bit mode is the 32-bit
memory addressing limitation.  Regretfully, I know of no
other workaround for this problem.  If you do come across a
solution for making LTI-Civil run in Snow Leopard or later
under 64-bit Java, please let me know.


E.  Directory Structure

The directory structure is arranged to provide the MATLAB .M
files called by the MATLAB script programmer, and the
underlying Java-based "glue" that these .M files reference.

bin - Underlying compiled Java "glue" for FrameGrabM that
   interfaces with the MATLAB code.
doc - JavaDoc for the underlying compiled Java "glue".
matlab - Contains the .M files that are of interest to a
   typical MATLAB user using FrameGrabM.
src - Source code for the underlying Java "glue".

After downloading LTI-CIVIL in Section B, Step 2, the
directory structure also contains:

lti-civil-20070920-1721 - The Java library plus native
   binary library files for LTI-CIVIL.


F.  Improvements

These are identified features that still have yet to be
completed:
- Automated install script
- LTI-CIVIL integration
- Mac OS X and Linux testing
- Frame drop alarms


G.  Function Reference

This is a list of all of the MATLAB functions for
FrameGrabM.  Parameters in [square brackets] are optional.
For convenience, most functions can be called from within
MATLAB as statements (e.g. no parentheses).

deviceList = FGRABM_DEVICES()
   FGRABM_DEVICES - obtains a list of all of the detected
   video devices and returns them as a structure array.  To
   use a particular device, refer to the deviceIndex value
   which is the same value as the array index.

formatList = FGRABM_FORMATS([device])
   FGRABM_FORMATS obtains a list of all formats supported
   by the given device (addressed as an index as given by
   FGRABM_DEVICES).  If no device index is given, then the
   default device is used.  Set a device to use a format by
   passing the formatIndex value (the same as the array
   index) to FGRABM_SETFORMAT

deviceIndex = FGRABM_GETDEFAULT()
   FGRABM_GETDEFAULT returns the default device ID.  The
   default device ID is used to refer to the capture device
   represented by the respective index of the structure
   array returned by FGRABM_DEVICES.

formatIndex = FGRABM_GETFORMAT([device])
   FGRABM_GETFORMAT returns the image format index that
   corresponds with the structure returned by
   FGRABM_FORMATS([device]).  If device is not specified,
   then the default device is used.

pixels = FGRABM_GRAB([device], [datatype], [fix])
   FGRABM_GRAB performs a frame grab on the given device
   (or the default device if none specified) and returns
   the following:
   For formats of type 'RGB24', an array with dimensions
   [rows][cols][3] where the three last indices are the RGB
   components,
   For formats of type 'RGB32', an array with dimensions
   [rows][cols][4], unless fix = true; then the return is
   [rows][cols][3].  Fix is defaulted to true.
   For formats of type 'unknown', an array with dimensions
   [data].
   
   Note that for 'RGB24' or fix = true (default), the
   output can be fed to the IMAGE function to display the
   captured image.
   
   By default, a UINT8 array is returned.  The following
   can be specified for datatype: 'uint8', 'single', and
   'double'.  For the first, the range of pixel data is 0
   to 255.  For the last two, the range of pixel data is
   rescaled to be 0 to 1.
   
   All parameters are optional, may be omitted, and only
   need to be specified in the order given.
   
   Note that to format the image data, the information
   returned from FGRABM_FORMATS is used.  The querying and
   string processing on that structure can be time-
   consuming.  To speed up the first FGRABM_GRAB operation,
   call FGRABM_FORMATS or FGRABM_START beforehand to have
   the information internally cached.
   
   Note also that if this is called without first calling
   FGRABM_START, the capture framework is started
   explicitly to capture one frame.  For capture devices
   that require warming up, it is recommended to first call
   FGRABM_START and then to wait using PAUSE before
   acquiring frames.

FGRABM_INIT()
   FGRABM_INIT is the first activity that must be performed
   to start up the underlying video capture library.  This
   produces a global variable FGRABM that will be used by
   other FrameGrabM functions.  Most other FrameGrabM
   functions will call FGRABM_INIT automatically if needed.

capturing = FGRABM_ISCAPTURING([device])
   FGRABM_ISCAPTURING returns true if a capture operation
   is underway.  A capture operation should be underway if
   FGRABM_START([device]) was called.  If device is not
   specified, then the default device is used.

initialized = FGRABM_ISINIT()
   FGRABM_ISINIT will return true if FrameGrabM and the
   underlying LTI-CIVIL library are already initialized.

FGRABM_SETDEFAULT(device)
   FGRABM_SETDEFAULT allows the default capture device to
   be set so that most function calls that take a device
   index as a parameter don't need the parameter specified-
   - the default will be used in its place.

FGRABM_SETFORMAT([device], format)
   FGRABM_SETFORMAT sets the image format according to the
   index of the structure array returned by FGRABM_FORMATS.
   Unless a device ID is given for the device parameter
   (e.g. it is skipped), the default device is used.

FGRABM_SHUTDOWN()
   FGRABM_SHUTDOWN gracefully shuts down the capture
   system, automatically stopping any processes that are
   underway.  It then deallocates the FGRABM global
   variable.

FGRABM_START([device])
   FGRABM_START begins the capture process in the
   underlying capture library.  After starting, frames will
   be continuously captured.  The latest individual frame
   may then obtained by calling FGRABM_GRAB.  Frames not
   grabbed will not be retained.  If device is not
   specified, then the default device is used.

FGRABM_STOP([device])
   FGRABM_STOP ends a capture process that was begun
   earlier with FGRABM_START.  If device is not specified,
   then the default device is used.


H.  Samples Reference

Three sample MATLAB scripts are included.  These can serve
as additional examples on how to use FrameGrabM.  These
include:

FGRABM_TEST - a short diagnostic for FrameGrabM to verify
proper functionality.  If FrameGrabM is properly installed,
you should see information on the default capture device and
format appear on the console and see a captured frame appear
in an image window.  If there is a malfunction, an exception
should be generated with an explanatory message.

SAMPLE_AVERAGE - uses FrameGrabM to grab a series of frames
and averages them together to reduce the amount of noise
that may appear in the image.  This is especially useful in
low-light situations.  This also shows a technique for
preallocation of memory to ensure that consecutive frames
are captured without gaps in time.

SAMPLE_TWOCAMS - starts capture processes for two cameras
and displays frames from each.  This sample code requires
that two valid capture devices be connected to the computer.

