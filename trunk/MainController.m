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
    [o_fileTypes release];
    [super dealloc];
}

- (void)initArrays
{
    NSArray * o_bmp;
    NSArray * o_gif;
    NSArray * o_jpeg;
    NSArray * o_png;
    NSArray * o_tiff;
    /* temp. arrays storing all properties of the respective file type in the
     * order: public name, file suffix, NSBitmapImageFileType, long name */
    o_bmp = [NSArray arrayWithObjects: @"BMP", @"bmp", \
        @"Device-Independent Bitmap", nil];
    o_gif = [NSArray arrayWithObjects: @"GIF", @"gif", \
        @"Graphics Interchange Format", nil];
    o_jpeg = [NSArray arrayWithObjects: @"JPEG", @"jpg", \
        @"Joint Photographic Experts Group", nil];
    o_png = [NSArray arrayWithObjects: @"PNG", @"png", \
        @"Portable Network Graphics", nil];
    o_tiff = [NSArray arrayWithObjects: @"TIFF", @"tiff", \
        @"Tagged Image File Format", nil];
    o_fileTypes = [[NSArray alloc] initWithObjects: o_bmp, o_gif, o_jpeg, \
        o_png, o_tiff, nil];
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
    /* not needed */
}

- (IBAction)setupOkay:(id)sender
{
    [o_setup_window close];
    [o_prog_stat_lbl setStringValue: @"Waiting..."];
    [o_prog_prog_lbl setStringValue: [NSString stringWithFormat: \
        @"Image %i of %i", 0, [o_files count]]];
    [o_prog_progBar setMaxValue: [o_files count]];
    [o_prog_progBar setDoubleValue: 0];
    [o_prog_window center];
    [o_prog_window makeKeyAndOrderFront: nil];

    SEL sel = @selector(savePanelDidEnd:returnCode:contextInfo:);
    openFolderPanel = [[NSOpenPanel alloc] init];
    [openFolderPanel setCanChooseDirectories: YES];
    [openFolderPanel setCanChooseFiles: YES];
    [openFolderPanel setResolvesAliases: YES];
    [openFolderPanel setAllowsMultipleSelection: NO];
    [openFolderPanel setTitle: @"Choose folder"];
    [openFolderPanel setMessage: @"Choose the folder to save your shrunked " \
        "file(s) to"];
    [openFolderPanel setCanCreateDirectories: YES];
    [openFolderPanel setPrompt: @"Select"];
    [openFolderPanel beginForDirectory: nil file: nil types: nil \
        modelessDelegate: self didEndSelector: sel contextInfo: nil];
}

- (void)savePanelDidEnd:(NSSavePanel * )panel returnCode: (int)returnCode contextInfo: (void *)contextInfo
{
    if( returnCode == NSOKButton )
    {
        [self processImages];
    }
    else
    {
        [o_prog_window close];
    }
}

- (void)processImages
{
    // okay, we've got all the settings, let's go finally
    NSImage * currentImage;
    NSImageRep * imageRep;
    NSDictionary * imageSavingProperties;
    NSData * imageSavingData;
    unsigned int x = 0;
    NSString * tempString;
    
    /* disable the indeterminate look and enable the threaded animation */
    [o_prog_progBar setIndeterminate: NO];
    [o_prog_progBar setUsesThreadedAnimation: YES];
    
    while( x != [o_files count] )
    {
        currentImage = [[NSImage alloc] initWithContentsOfFile: \
            [o_files objectAtIndex: x]];
    
        imageRep = [currentImage bestRepresentationForDevice:nil];
        if (![imageRep isKindOfClass:[NSBitmapImageRep class]])
        {
            if( [o_files count] == 1 )
            {
                /* we are only processing one file, let's tell the user that his
                 * file is crap */
                NSRunAlertPanel( @"Unsupported file type",
                    @"The file you selected isn't supported by your version " \
                    "of QuickTime", @"OK", nil, nil );
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
            imageSavingData = [(NSBitmapImageRep *)imageRep \
                representationUsingType: NSJPEGFileType 
                             properties: imageSavingProperties];
            tempString = [[NSFileManager defaultManager] displayNameAtPath: \
                [o_files objectAtIndex: x]];
            [imageSavingData writeToFile: [[[openFolderPanel directory] \
                stringByAppendingString: @"/"] \
                stringByAppendingString: tempString] atomically: YES];

            NSLog( [NSString stringWithFormat: @"processed file %i of %i", (x + 1), [o_files count]] );

            [currentImage release];
            x = (x + 1);
        }
        [o_prog_progBar incrementBy: 1];
    }

    [o_prog_window close];
    /* enable the indeterminate look again and disable the threaded animation */
    [o_prog_progBar setIndeterminate: NO];
    [o_prog_progBar setUsesThreadedAnimation: YES];

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
            [self initArrays];
            [self initSetupWindow];
        }

        o_files = [o_openPanel filenames];
        
        [o_setup_window makeKeyAndOrderFront:nil];
        [o_files retain];
    }
}

- (void) initSetupWindow
{
    unsigned int x = 0;
    [o_setup_fileFormat_pop removeAllItems];
    while( x != [o_fileTypes count] )
    {
        [o_setup_fileFormat_pop addItemWithTitle: \
            [[o_fileTypes objectAtIndex: x] objectAtIndex: 0]];
        x = (x + 1);
    }
    
    /* FIXME: select the items as stored on last exit */
    /* select the JPEG item and show its long name */
    [o_setup_fileFormat_pop selectItemWithTitle: @"JPEG"];
    // FIXME fix this crappy crap when you've got too much spare time
    [o_setup_fileFormat_longName_lbl setStringValue: \
        [[o_fileTypes objectAtIndex: 2] objectAtIndex: 2]];
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
