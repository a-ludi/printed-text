/**
    API definitions for this package. Implementations must adhere to these
    interfaces.

    Copyright: © 2021 Arne Ludwig <arne.ludwig@posteo.de>
    License: Subject to the terms of the MIT license, as written in the
             included LICENSE file.
    Authors: Arne Ludwig <arne.ludwig@posteo.de>
*/
module printed.text.api;

import printed.canvas;
import printed.font;
import printed.text.util;


/// Available text alignment modes.
enum TextAlign
{
    /// Align to the start edge of the text (left side in left-to-right text, right side in right-to-left text).
    /// This is the default.
    start,

    /// Align to the end edge of the text (right side in left-to-right text, left side in right-to-left text).
    end,

    /// Align to the left.
    left,

    /// Align to the right.
    right,

    /// Align to the center.
    center,

    /// The line contents are justified. Text should be spaced to line up its
    /// left and right edges to the left and right edges of the line box,
    /// except for the last line.
    justify,
}


/// The scope various attributes apply to while creating text layouts.
///
/// For example, the font face, style, weight and size apply to all characters
/// that are written while they are in effect while line spacing and text
/// alignment apply to whole paragraphs.
enum TextLayoutScope
{
    /// Attributes in this scope apply to all characters that are written
    /// using `write()` after setting them.
    ///
    /// Examples:
    ///
    /// ```
    /// fontSize = 12;
    /// fontWeight = FontWeight.bold;
    ///
    /// write("Hello\n"); // produces a single line containing the word
    ///                   // "Hello" in bold letters and font size 12
    /// write("World\n"); // same font size and weight
    ///
    /// fontWeight = FontWeight.normal;
    ///
    /// write("How are you?"); // This line will have normal font weight
    /// ```
    character,
    /// Attributes in this scope apply to the paragraphs that are ended
    /// explicitly by `endParagraph()` or implicitly by `layout()`.
    ///
    /// Examples:
    ///
    /// ```
    /// lineSpacing = 1f;
    ///
    /// write("Hello World");
    /// endParagraph(); // This paragraph will have a regular line spacing
    ///
    /// lineSpacing = 2f;
    ///
    /// write("How are you?");
    /// endParagraph(); // This paragraph has double line spacing
    ///
    /// write("So long, and thanks for all the fish.")
    /// layout(); // The last paragraph also has double line spacing.
    /// ```
    paragraph,
    /// Attributes in this scope apply to the pages that are ended
    /// explicitly by `endPage()` or implicitly by `layout()`.
    ///
    /// Examples:
    ///
    /// ```
    /// textWidth = 210f;
    ///
    /// write("Hello World");
    /// endPage(); // This page will have a width of 210mm
    ///
    /// textWidth = 105f;
    ///
    /// write("How are you?");
    /// endPage(); // This page has a width of 105mm
    ///
    /// write("So long, and thanks for all the fish.")
    /// layout(); // The last page also has a width of 105mm
    /// ```
    page,
}


/// Main interface for creating text layouts with simple text formatting
/// like varying fonts, font sizes etc. and structural cues like manual
/// paragraph and page breaks.
interface ITextLayouter
{
    /// Size of the area were the text is laid out. The text is automatically
    /// broken across pages. Both dimensions may be infinite which suppresses
    /// line breaks in case of the width and page breaks in case of the
    /// height.
    ///
    /// Scope: `TextLayoutScope.page`
    void textWidth(float x);
    /// ditto
    float textWidth();
    /// ditto
    void textHeight(float y);
    /// ditto
    float textHeight();

    /// Current line spacing relative to the current font size.
    ///
    /// Scope: `TextLayoutScope.paragraph`
    void lineSpacing(float factor);
    /// ditto
    float lineSpacing();

    /// Current text alignment strategy.
    ///
    /// Scope: `TextLayoutScope.paragraph`
    void textAlign(TextAlign align_);
    /// ditto
    TextAlign textAlign();

    /// End the current and start a new paragraph. The first paragraph is
    /// created implicitly and the last paragraph should not be closed.
    /// Closing it will create an empty paragraph which may consume space of
    /// the text area.
    void endParagraph();

    /// Continue layout on a new page.
    void endPage();

    /// Current font size.
    ///
    /// Scope: `TextLayoutScope.character`
    void fontSize(float mm);
    /// ditto
    float fontSize();

    /// Current text color.
    ///
    /// Scope: `TextLayoutScope.character`
    void color(Brush color);
    /// ditto
    Brush color();

    /// Current font size.
    ///
    /// Scope: `TextLayoutScope.character`
    void fontFace(string face);
    /// ditto
    string fontFace();

    /// Current font weight.
    ///
    /// Scope: `TextLayoutScope.character`
    void fontWeight(FontWeight weight);
    /// ditto
    FontWeight fontWeight();

    /// Current font style.
    ///
    /// Scope: `TextLayoutScope.character`
    void fontStyle(FontStyle style);
    /// ditto
    FontStyle fontStyle();

    /// Save the current state of the specified scope, i.e. `fontSize`, `color`, `fontFace`,
    /// `fontWeight`, `fontStyle` and `textAlign`.
    void save(TextLayoutScope scope_);

    /// Restore the last saved state.
    ///
    /// See_also: `save()`
    void restore(TextLayoutScope scope_);

    /// Append `text` to the current page.
    ///
    /// The alias `put` makes `ITextLayouter` act as an output range for
    /// strings.
    void write(string text);
    /// ditto
    void write(char text);
    /// ditto
    alias put = write;

    /// Compute the text layout with the current text and text dimensions and
    /// return the pages which can be rendered by an `IRenderingContext2D`.
    ILayoutBlock[] layout(ILocale locale = null);

    /// Clear all text buffers.
    void clear();
}


/// Wrap `yield` with `save()` and `restore()`.
void group(
    ITextLayouter layouter,
    TextLayoutScope scope_,
    void delegate() yield,
)
in (layouter !is null)
{
    layouter.save(scope_);
    yield();
    layouter.restore(scope_);
}

///
unittest
{
    void varyingTextSize(ITextLayouter layouter) {
        layouter.write("Small text. ");
        layouter.group(TextLayoutScope.character, {
            layouter.fontSize = 12f;

            layouter.write("Large text. ");
        });
        layouter.write("Small again.");
    }
}


/// Defines how a text is split into words and words into syllables and
/// provides the hyphen character used for hyphenation.
interface ILocale
{
    /// Returns slices of `text` that represent individual words interleaved
    /// with the content that separates them.
    string[] breakWords(string text)
    out (words; words.isPartitionOf(text));

    /// Returns slices of `word` that represent its syllables.
    string[] breakSyllables(string word)
    out (syllables; syllables.isPartitionOf(word));

    /// Character used for hyphenation.
    wchar hypen();
}


/// Represents a laid out text of a single page that can be rendered using a
/// `IRenderingContext2D`.
interface ILayoutBlock
{
    /// Render this layout block with `renderer` and an offset of given by
    /// `x` and `y`.
    void renderWith(IRenderingContext2D renderer, float x = 0f, float y = 0f);

    /// Return the text size that was in effect when this layout was created.
    float textWidth();
    /// ditto
    float textHeight();

    /// Return the size of the area that will be filled with content when
    /// rendering.
    float filledWidth();
    /// ditto
    float filledHeight();
}
