# Copyright (c) 2007-2012, Michael J. Kahana.
#
# This file is part of PandaEPL.
#
# PandaEPL is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 2.1 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Alec Solway
# URL: http://memory.psych.upenn.edu/PandaEPL

from Camera               import Camera
from Log                  import Log
from Tuples               import *
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from Vr                   import Vr
from VrObject             import VrObject
from ptime                import *
from pandac.PandaModules  import ConfigVariable, NodePath, TextNode

class Text(VrObject, UniquelyIdentifiable):
 
    Log.getInstance().addType("TEXT_INIT", [('identifier',basestring)])
    Log.getInstance().addType("TEXT_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("TEXT_COLOR", [('identifier',basestring), ('value', VBase4)])
    Log.getInstance().addType("TEXT_FONT", [('identifier',basestring), ('value',basestring)])
    Log.getInstance().addType("TEXT_SHADOWCOLOR", [('identifier',basestring), ('value',VBase4)])
    Log.getInstance().addType("TEXT_SHADOWPOS", [('identifier',basestring), ('value',VBase2)])
    Log.getInstance().addType("TEXT_STRING", [('identifier',basestring), ('value',basestring)])
    Log.getInstance().addType("TEXT_WORDWRAP", [('identifier',basestring), ('width',Log.number)])
    Log.getInstance().addType("TEXT_DOWRAP", [('identifier',basestring)])
 
    def __init__(self, identifier, text, pos, scale, color, fontFile=None):
        """
        Creates a Text object. By default, it appears in "front" of
        the VR environment.

        identifier - string, a unique identifier for this object
        text       - string, the text to display.
        pos        - Point3, position of the text. If the text
                     is in "front" of the VR environment (default),
                     only the x and z components of the position
                     are used; each is in the range [-1, 1].
        scale      - Point3, text size. If the text sticks to the
                     screen, the same rules apply as for 'pos'.
        color      - Point4
        fontFile   - string, path to a FreeType supported font file.
        """
        Log.getInstance().writeLine((mstime(), 0), "TEXT_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        textNode = TextNode(identifier)
        VrObject.__init__(self, identifier, NodePath(textNode))

        # This is the height of the first line, used
        # to transform the Z coordinate of text to make 
        # it appear as if it starts in the top-left corner 
        # (see getPos(..)/setPos(..) for more). This is done 
        # only once per property change for efficiency sake.
        self.firstLineHeight = 0

        self.setWordwrap(None)
        self.setText(text)
        self.setSticksToScreen(True)
        if fontFile!=None:
            self.setFont(fontFile)
        self.setColor(color)

        textNode.setAlign(TextNode.ALeft) # pos is then where text begins.
 
        self.setPos(pos)
        self.setScale(scale)
        VLQ.getInstance().writeLine("TEXT_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def __doWrap(pandaNodePath, maxWidth):
        """
        Private

        Inserts newline characters into text so that each line
        is no longer than maxWidth screen units wide. Screen units
        are on the interval [-1, 1]. All whitespace other than newline
        is collapsed into a space. pandaNodePath is a NodePath pointing
        to a TextNode where the text is held. Returns the new text.
        """
        # Buffer to hold new text with added newlines.
        newText     = []

        # Buffer to hold each line of text as it's processed.
        currentLine = []

        for line in pandaNodePath.node().getText().split("\n\n"):
            for word in line.split():
                # Add the next word to the line.
                currentLine.append(word)

                # Calculate the total width of the line with the new word.
                width = pandaNodePath.node().calcWidth("".join(currentLine)) * \
                          (pandaNodePath.getScale().getX() / \
                           Camera.getDefaultCamera().getAspectRatio())
                # NOTE: If the aspect ratio of the main camera is ever changed mid-game 
                # after wordwrap has been set, then the text will not automatically 
                # re-wrap properly with the new ratio. Since at present this behavior is 
                # not expected, we opt to leave this as-is and not set up a messaging
                # system to update text objects when the aspect ratio of the main camera
                # changes.
    
                # If the line width exceeds the requested width, remove the current word,
                # add a newline character, add the new line to the text buffer, and 
                # start a new line soley with the new word. Otherwise, append a space
                # and proceed to the next word.
                if width > maxWidth:
                    currentLine.pop()
                    currentLine.append("\n")
                    newText.extend(currentLine)
                    currentLine = [word, " "]
                else:
                    currentLine.append(" ")

            # Force flush the line at a double newline, even if the width
            # has not been reached.
            currentLine.append("\n\n")
            if len(currentLine) != 0:
                newText.extend(currentLine)
                currentLine = []

        # Add any remaining words to the new text buffer.
        newText.extend(currentLine)

        return "".join(newText)

    __doWrap = staticmethod(__doWrap)

    def __updateFirstLineHeight(self):
        """
        Updates the height of the first line using the 
        currently set text.
        """
        pos       = self.getPos()
        text      = self.getText()
        firstLine = text.split("\n")[0]
        self.retrNodePath().node().setText(firstLine)
        bounds    = self.retrNodePath().getTightBounds()
        self.firstLineHeight = bounds[1][2]-bounds[0][2]
        self.retrNodePath().node().setText(text)

        # Reset text position to use new line height.
        self.setPos(pos)

    def __wrap(self):
        """
        Private

        Inserts newline characters into the currently set text
        so that each line is no wider than the width set by
        the wordwrap property.
        """
        if self.wordwrap == None:
            self.__updateFirstLineHeight()
            return

        self.retrNodePath().node().setText(Text.__doWrap(self.retrNodePath(), \
                                                         self.wordwrap))
        VLQ.getInstance().writeLine("TEXT_DOWRAP", [self.getIdentifier()])
        self.__updateFirstLineHeight()
    
    def hasShadow(self):
        """
        Returns a boolean specifying whether the text has
        a shadow.
        """
        return self.retrNodePath().node().hasShadow()

    def hasWordwrap(self):
        """
        Returns a boolean specifying whether the text has
        a set width at which to wrap.
        """
        return (self.wordwrap != None)

    def getColor(self):
        """
        Returns the text color.
        """
        return self.retrNodePath().node().getTextColor()

    def getFontFile(self):
        """
        Returns the name of the font file used.
        """
        return self.fontFile

    def getHeight(self):
        """
        Returns the height of the text in screen units
        (the screen spans the interval [-1, 1]).
        """
        return self.retrNodePath().node().getHeight() * \
                self.retrNodePath().getScale().getZ()

    def getPos(self):
        """
        Returns a Point3 containing the object's position.

        Hides the fact that internally, a text object's
        vertical position represents the baseline of the
        first line and makes it appear as if the position
        represents the top left corner instead.
        """
        pos = VrObject.getPos(self)
        return Point3(pos.getX(), pos.getY(), pos.getZ() + self.firstLineHeight)

    def getShadowColor(self):
        """
        Returns the color of the text's shadow, a Point4.
        None if shadows are disabled.
        """
        if self.retrNodePath().node().hasShadow():
            return self.retrNodePath().node().getShadowColor()

        return None

    def getShadowPos(self):
        """
        Returns the position of the text's shadow relative
        to the text, a Vec2. None if shadows are disabled.
        """
        if self.retrNodePath().node().hasShadow():
            return self.retrNodePath().node().getShadow()

        return None

    def getText(self):
        """
        Returns the text.
        """
        return self.retrNodePath().node().getText()

    def getWidth(self):
        """
        Returns the width of the text in screen units
        (the screen spans the interval [-1, 1]).
        """
        return self.retrNodePath().node().getWidth() * \
                self.retrNodePath().getScale().getX()

    def getWordwrap(self):
        """
        Returns the maximum width of the text in screen 
        units (the screen spans the interval [-1, 1]). 
        None if wordwrap is disabled.
        """
        return self.wordwrap

    def setColor(self, newColor):
        """
        Sets the text color (Point4).
        """
        self.retrNodePath().node().setTextColor(newColor)
        VLQ.getInstance().writeLine("TEXT_COLOR", [self.getIdentifier(), newColor])

    def setFont(self, newFontFile):
        """
        Sets a new FreeType supported font file to use.
        """
        self.fontFile = newFontFile
        self.retrNodePath().node().setFont(base.loader.loadFont(newFontFile))
        VLQ.getInstance().writeLine("TEXT_FONT", [self.getIdentifier(), newFontFile])
        self.__wrap()

    def setPos(self, newPos):
        """
        Sets the object's position (Point3).

        Hides the fact that internally, a text object's
        vertical position represents the baseline of the
        first line and makes it appear as if the position
        represents the top left corner instead.
        """
        newPos = Point3(newPos.getX(), newPos.getY(), newPos.getZ() - self.firstLineHeight)
        VrObject.setPos(self, newPos)

    def setScale(self, newScale):
        """
        Sets the object's scale components (Point3).
        If given a single value, all three components
        are set to that same value.
        """
        VrObject.setScale(self, newScale)
        self.__wrap()

    def setShadowColor(self, newShadowColor):
        """
        Sets the color of the text's shadow, a Point4.
        """
        self.retrNodePath().node().setShadowColor(newShadowColor)
        VLQ.getInstance().writeLine("TEXT_SHADOWCOLOR", [self.getIdentifier(), newShadowColor])

    def setShadowPos(self, newShadowPos):
        """
        Sets the position of the text's shadow relative
        to the text, a Vec2. If None, clears the shadow.
        """
        if newShadowPos == None:
            self.retrNodePath().node().clearShadow()
        else:
            self.retrNodePath().node().setShadow(newShadowPos)
        VLQ.getInstance().writeLine("TEXT_SHADOWPOS", [self.getIdentifier(), newShadowPos])

    def setText(self, newText):
        """
        Sets the text.
        """
        if isinstance(newText, unicode):
            self.retrNodePath().node().setEncoding(TextNode.EUtf8)
            self.retrNodePath().node().setText(newText.encode("utf-8"))
        else:
            self.retrNodePath().node().setEncoding(TextNode.EIso8859)
            self.retrNodePath().node().setText(newText)
        VLQ.getInstance().writeLine("TEXT_STRING", [self.getIdentifier(), newText[0:24]])
        self.__wrap()

    def setWordwrap(self, newWordwrap):
        """
        Sets the width of the text in screen units
        (the screen spans the interval [-1, 1]).
        If None, clears wrapping.
        """
        self.wordwrap = newWordwrap
        VLQ.getInstance().writeLine("TEXT_WORDWRAP", [self.getIdentifier(), newWordwrap])
        self.__wrap()

