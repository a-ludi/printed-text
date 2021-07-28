/**
    Utility functions that are being used by this package. Currently this is
    only `isPartitionOf` which is being used in function contracts that are
    part of the public API.

    Copyright: © 2021 Arne Ludwig <arne.ludwig@posteo.de>
    License: Subject to the terms of the MIT license, as written in the
             included LICENSE file.
    Authors: Arne Ludwig <arne.ludwig@posteo.de>
*/
module printed.text.util;


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
