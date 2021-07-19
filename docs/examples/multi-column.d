#!/usr/bin/env dub
/+ dub.sdl:
    dependency "printed:canvas" version="~>1.1.2"
    dependency "printed:font"   version="~>1.1.2"
    dependency "printed-text"   path="../.."
+/
module printed.text.examples.multi_column;

import printed.canvas;
import printed.text;
import std.string;

enum fontFace = "Arial";
enum fontSize = 12f;
enum headerFontSize = 2f*fontSize;
enum pageWidth = 140f;
enum pageHeight = 210f;
enum pagePadding = 10f;
enum columnGap = 10f;
enum numColumns = 2;
enum headerMarginBottom = 8f;
enum paragraphMarginVertical = 12f;

void main()
{
    //printExample();
    assert(0, "implement!");
}

void printExample(IRenderingContext2D renderer, ITextLayouter textLayouter)
{
    //renderer.pageWidth = pageWidth;
    //renderer.pageHeight = pageHeight;

    with (textLayouter)
    {
        // basic configuration
        textWidth = pageWidth - 2f*pagePadding;
        fontFace = .fontFace;
        fontSize = .fontSize;

        save();
            fontSize = .headerFontSize;
            fontWeight = FontWeight.bold;
            write("Lorem Ipsum");
            auto headerBlock = layout()[0];
            clear();
        restore();

        const columnWidth = (textWidth - (numColumns - 1)*columnGap) / numColumns;
        const columnHeight = pageHeight - 2f*pagePadding - headerBlock.filledHeight;

        textWidth = columnWidth;
        textHeight = columnHeight;

        textLayouter.group({
            fontStyle = FontStyle.italic;
            write("Lorem ipsum dolor sit amet");
        });
        write(", consectetur adipisici elit, sed eiusmod tempor incidunt ut ");
        write("labore et dolore magna aliqua. Ut enim ad minim veniam, quis ");
        write("nostrud exercitation ullamco laboris nisi ut aliquid ex ea ");
        write("commodi consequat. Quis aute iure reprehenderit in voluptate ");
        write("velit esse cillum dolore eu fugiat nulla pariatur. Excepteur ");
        write("sint obcaecat cupiditat non proident, sunt in culpa qui ");
        write("officia deserunt mollit anim id est laborum.");
        endParagraph();

        write("Duis autem vel eum ");
        save();
            fontWeight = FontWeight.bold;
            write("iriure");
        restore();
        write(" dolor in hendrerit in vulputate velit esse molestie ");
        write("consequat, vel illum dolore eu feugiat nulla facilisis at ");
        write("vero eros et accumsan et iusto odio dignissim qui blandit ");
        write("praesent luptatum zzril delenit augue duis dolore te feugait ");
        write("nulla facilisi. Lorem ipsum dolor sit amet, consectetuer ");
        write("adipiscing elit, sed diam nonummy nibh euismod tincidunt ut ");
        write("laoreet dolore magna aliquam erat volutpat.");
        endParagraph();
        write(`
            Ut wisi enim ad minim veniam, quis nostrud exerci tation ut
            aliquip ex ea commodo. eum iriure dolor in hendrerit in
            molestie consequat, illum dolore eu feugiat nulla facilisis
            at vero eros et accumsan et iusto odio dignissim qui blandit
            praesent luptatum zzril delenit augue duis dolore te feugait
            nulla facilisi.
        `.stripLeft("\n").stripRight.outdent);
        endParagraph();

        write("Duis autem vel eum iriure dolor in hendrerit in vulputate ");
        write("velit esse molestie consequat, vel illum dolore eu feugiat.");
        endParagraph();

        write(q"EOS
Consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore
et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et
justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur
sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et.
EOS".replace("\n", " "));

        auto columns = layout();
        assert(columns.length == 2);

        renderer.save();
            renderer.translate(pagePadding, pagePadding);
            headerBlock.renderWith(renderer);

            auto columnOffsetX = 0f;
            const columnOffsetY = headerBlock.filledHeight + headerMarginBottom;
            foreach (column; columns)
            {
                column.renderWith(renderer, columnOffsetX, columnOffsetY);
                columnOffsetX += column.filledWidth + columnGap;
            }
        renderer.restore();
    }
}
