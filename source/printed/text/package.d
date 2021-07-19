/**
    Text layout engine on top of `printed` graphics package.

    Copyright: © 2021 Arne Ludwig <arne.ludwig@posteo.de>
    License: Subject to the terms of the MIT license, as written in the
             included LICENSE file.
    Authors: Arne Ludwig <arne.ludwig@posteo.de>
*/
module printed.text;

import printed.canvas;
import printed.font;


interface ITextLayouter
{
    /// Set or get the size of the area were the text is laid out. The text is
    /// automatically broken across pages. Both dimensions may be infinite
    /// which suppresses line breaks in case of the width and page breaks in
    /// case of the height.
    ///
    /// See_also: `newText()`
    void textWidth(float x);
    /// ditto
    float textWidth();
    /// ditto
    void textHeight(float y);
    /// ditto
    float textHeight();

    /// Set the current line spacing relative to the current font size. This
    /// applies to all subsequent pages until it is changed.
    void lineSpacing(float factor);

    /// End the current and start a new paragraph. The first paragraph is
    /// created implicitly. This is equivalent to writing two newline
    /// characters:
    ///
    ///     writeln();
    ///     writeln();
    ///
    /// Two or more newline characters separate paragraphs.
    void endParagraph();

    /// Continue layout on a new page.
    void endPage();

    /// Set the current font size. This applies to all subsequent text until
    /// it is changed.
    void fontSize(float mm);

    /// Set the text color. This applies to all subsequent text until it is
    /// changed.
    void color(Brush color);

    /// Set the current font size. This applies to all subsequent text until
    /// it is changed.
    void fontFace(string face);

    /// Set the current font weight. This applies to all subsequent text until
    /// it is changed.
    void fontWeight(FontWeight weight);

    /// Set the current font style. This applies to all subsequent text until
    /// it is changed.
    void fontStyle(FontStyle style);

    /// Save the current state, i.e. `fontSize`, `color`, `fontFace`,
    /// `fontWeight` and `fontStyle`.
    void save();

    /// Restore the last saved state.α
    ///
    /// See_also: `save()`
    void restore();

    /// Append `text` to the current page.
    ///
    /// The alias `put` makes `ITextLayouter` act as an output range for
    /// strings.
    void write(string text);
    /// ditto
    alias put = write;

    /// Compute the text layout with the current text and text dimensions and
    /// return the pages which can be rendered by an `IRenderingContext2D`.
    ILayoutBlock[] layout(ILocale locale = null);

    /// Clear all text buffers.
    void clear();
}


void group(ITextLayouter layouter, void delegate() yield)
{
    layouter.save();
    yield();
    layouter.restore();
}


/// Defines how a text is split into words and words into syllables and
/// provides the hyphen character used for hyphenation.
interface ILocale
{
    import std.array : join;

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


/// Returns true iff `parts` is a partition of `whole`. This is equivalent
/// to `join(parts) == whole` but more efficient.
bool isPartitionOf(T)(const T[][] parts, const T[] whole) pure nothrow @safe @nogc
{
    alias haveSameElements = {
        size_t i;

        foreach (part; parts)
            foreach (element; part)
                if (element != whole[i++])
                    return false;

        return true;
    };
    alias adjancentInMemory = (lhs, rhs) @trusted {
        return &lhs[0] + lhs.length == &rhs[0];
    };
    alias countElementsInParts = {
        size_t elementsInParts;
        foreach (part; parts)
            elementsInParts += part.length;

        return elementsInParts;
    };

    if (parts.length == 0)
        return false;
    else if (whole.length == 0)
        return parts.length == 1 && parts[0].length == 0;
    else if (&parts[0][0] != &whole[0])
        return haveSameElements();
    else if (countElementsInParts() != whole.length)
        return false;

    foreach (i, part; parts[1 .. $])
        if (!adjancentInMemory(parts[i], part))
            return haveSameElements();

    return true;
}

///
unittest
{
    enum text = "lorem ipsum dolor sit amet";
    enum words = [
        text[0 .. 5],
        text[5 .. 6],
        text[6 .. 11],
        text[11 .. 12],
        text[12 .. 17],
        text[17 .. 18],
        text[18 .. 21],
        text[21 .. 22],
        text[22 .. 26],
    ];

    assert(words.isPartitionOf(text));
}

unittest
{
    auto text = "lorem ipsum dolor sit amet";
    auto words = [
        text[0 .. 5],
        text[5 .. 6],
        text[6 .. 11],
        text[11 .. 12],
        text[12 .. 17],
        text[17 .. 18],
        text[18 .. 21],
        text[21 .. 22],
        text[22 .. 26],
    ];

    assert(words.isPartitionOf(text));
}

unittest
{
    auto text = "lorem ipsum dolor sit amet";
    auto words = [text[]];

    assert(words.isPartitionOf(text));
}

unittest
{
    auto text = "";
    auto words = [text[]];

    assert(words.isPartitionOf(text));
}

unittest
{
    auto text = "lorem ipsum dolor sit amet";
    auto words = [text[0 .. 5]];

    assert(!words.isPartitionOf(text));
}

unittest
{
    auto text = "lorem ipsum dolor sit amet";
    string[] words = [];

    assert(!words.isPartitionOf(text));
}