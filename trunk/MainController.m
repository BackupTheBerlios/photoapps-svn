/*****************************************************************************
 * MainController.m: MainController class. Does everything atm.
 *****************************************************************************
 * Copyright (C) Felix KŸhne, 2005
 * $Id$
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.
 *****************************************************************************/

#import "MainController.h"

@implementation MainController

- (void)dealloc
{
    [o_openPanel release];
    [o_savePanel release];
    [o_files release];
    [super dealloc];
}

- (IBAction)dropAction:(id)sender
{
}

- (IBAction)setupCancel:(id)sender
{
    [o_setup_window close];
}

- (IBAction)setupFileFormatChanged:(id)sender
{
}

- (IBAction)setupOkay:(id)sender
{
    // okay, we've got all the settings, let's go finally
    NSImage * currentImage;
    NSImageRep * imageRep;
    NSDictionary * imageSavingProperties;
    NSData * imageSavingData;
    unsigned int x = 0;

    [o_setup_window close];
    
    while( x != [o_files count] )
    {
        currentImage = [[NSImage alloc] initWithContentsOfFile: [o_files objectAtIndex: x]];
    
        imageRep = [currentImage bestRepresentationForDevice:nil];
        if (![imageRep isKindOfClass:[NSBitmapImageRep class]])
        {
            if( [o_files count] == 1 )
            {
                /* we are only processing one file, let's tell the user that his
                 * file is crap */
                NSRunAlertPanel( @"Unsupported file type",
                         @"The file you selected isn't supported by your version of QuickTime",
                         @"OK", nil, nil );
                return;
            } else {
                /* we are processing multiple files. don't confront the user
                 * with dozens of error messages and skip this crappy file */
                NSLog( [NSString stringWithFormat: @"skipped file %i", (x + 1)] );
                [currentImage release];
                x = (x + 1);
            }
        } else {
        imageSavingProperties = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat: ([o_setup_fileSize_sld floatValue] / 100)], \
            NSImageCompressionFactor, nil];
        imageSavingData = [(NSBitmapImageRep*)imageRep
            representationUsingType: NSJPEGFileType
                         properties: imageSavingProperties];
        [imageSavingData writeToFile: [NSString stringWithFormat: @"/Users/fpk/Desktop/Test/meins (%i).jpg", x] atomically:YES];

        NSLog( [NSString stringWithFormat: @"processed file %i of %i", (x + 1 ), [o_files count]] );

        [currentImage release];
        x = (x + 1);
        }
    }

    NSLog( @"Success!" );
}

- (IBAction)fileNew:(id)sender
{
    [o_drop_window makeKeyAndOrderFront:nil];
}

- (IBAction)fileClose:(id)sender
{
    [o_drop_window close];
}

- (IBAction)fileOpen:(id)sender
{
    o_openPanel = [[NSOpenPanel alloc] init];
    SEL sel = @selector(openPanelDidEnd:returnCode:contextInfo:);
    [o_openPanel setCanChooseFiles: YES];
    [o_openPanel setCanChooseDirectories: YES];
    [o_openPanel setResolvesAliases: YES];
    [o_openPanel setAllowsMultipleSelection: YES];
    [o_openPanel beginForDirectory: nil file: nil types: \
        [NSImage imageFileTypes] modelessDelegate: self didEndSelector: sel \
        contextInfo: nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if( returnCode == NSOKButton )
    {
        if(! setupWindowInited )
        {
            [self initSetupWindow];
        }
        
        o_files = [o_openPanel filenames];
        
        [o_setup_window makeKeyAndOrderFront:nil];
        [o_files retain];
    }
}

- (void) initSetupWindow
{
    [o_setup_fileFormat_pop removeAllItems];
    [o_setup_fileFormat_pop addItemsWithTitles: [NSArray arrayWithObjects: \
        @"BMP", @"GIF", @"JPEG", @"JPEG 2000", @"PNG", @"TIFF", nil]];
    [o_setup_fileFormat_pop selectItemWithTitle: @"JPEG"];
    setupWindowInited = YES;
}

- (IBAction)showLicense:(id)sender
{
	/* taken from VLC's OSX module. method is written by Derk-Jan Hartman. */
    NSString * o_path = [[NSBundle mainBundle] 
                pathForResource: @"COPYING" ofType: nil];
    [[NSWorkspace sharedWorkspace] openFile: o_path 
                withApplication: @"TextEdit"];
}

- (IBAction)progCancel:(id)sender
{
}

@end
