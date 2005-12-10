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
     * order: public name, file suffix */
    o_bmp = [NSArray arrayWithObjects: @"BMP", @"bmp", nil];
    o_gif = [NSArray arrayWithObjects: @"GIF", @"gif", nil];
    o_jpeg = [NSArray arrayWithObjects: @"JPEG", @"jpg", nil];
    o_png = [NSArray arrayWithObjects: @"PNG", @"png", nil];
    o_tiff = [NSArray arrayWithObjects: @"TIFF", @"tif", nil];
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
    [openFolderPanel beginForDirectory: nil file: nil types: [NSArray array] \
        modelessDelegate: self didEndSelector: sel contextInfo: nil];
}

- (void)savePanelDidEnd:(NSOpenPanel * )panel returnCode: (int)returnCode contextInfo: (void *)contextInfo
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
    /* okay, we've got all the settings, let's go finally */
    NSImage * currentImage;
    NSImageRep * imageRep;
    NSDictionary * imageSavingProperties;
    NSData * imageSavingData;
    unsigned int x = 0;
    int y = 0;
    NSString * tempString;
    NSString * tempPath;
    
    /* disable the indeterminate look and enable the threaded animation */
    [o_prog_stat_lbl setStringValue: @"Dwarfing your images..."];
    [o_prog_progBar setIndeterminate: NO];
    [o_prog_progBar setUsesThreadedAnimation: YES];
    [o_prog_window display];
    
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
                exit;
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
            
            /* check to which file-format we are exporting; we need to do this
             * like that because the representation type's constant is no valid
             * Cocoa object */
            if( [o_setup_fileFormat_pop titleOfSelectedItem] == @"JPEG" )
            {
                imageSavingData = [(NSBitmapImageRep *)imageRep \
                    representationUsingType: NSJPEGFileType 
                             properties: imageSavingProperties];
            } 
            else if( [o_setup_fileFormat_pop titleOfSelectedItem] == @"GIF" )
            {
                imageSavingData = [(NSBitmapImageRep *)imageRep \
                    representationUsingType: NSGIFFileType 
                             properties: imageSavingProperties];
            }
            else if( [o_setup_fileFormat_pop titleOfSelectedItem] == @"BMP" )
            {
                imageSavingData = [(NSBitmapImageRep *)imageRep \
                    representationUsingType: NSBMPFileType 
                             properties: imageSavingProperties];
            }
            else if( [o_setup_fileFormat_pop titleOfSelectedItem] == @"PNG" )
            {
                imageSavingData = [(NSBitmapImageRep *)imageRep \
                    representationUsingType: NSPNGFileType 
                             properties: imageSavingProperties];
            }
            else if( [o_setup_fileFormat_pop titleOfSelectedItem] == @"TIFF" )
            {
                imageSavingData = [(NSBitmapImageRep *)imageRep \
                    representationUsingType: NSTIFFFileType 
                             properties: imageSavingProperties];
            } else {
                NSRunAlertPanel( @"Unsupported output file type",
                    @"The file-format you selected isn't supported by this " \
                    "version of this application. This needs fixing. Please " \
                    "report that to the author(s).", @"OK", nil, nil );
                return;
            }
            tempString = [[NSFileManager defaultManager] displayNameAtPath: \
                [o_files objectAtIndex: x]];
            tempPath = [[[[[openFolderPanel directory]
                stringByAppendingString: @"/"]
                stringByAppendingString: tempString]
                stringByAppendingString: @"."]
                stringByAppendingString: [[o_fileTypes objectAtIndex:
                [o_setup_fileFormat_pop indexOfSelectedItem]] objectAtIndex: 1]];
                
            /* check whether a file exists yet and add an int to our name in 
             * case */
            if( [[NSFileManager defaultManager] fileExistsAtPath: tempPath] )
            {
                /* FIXME: we are screwed for the moment and need to replace
                 * the existing file */ 
                /*y = 1;
                while( y < 100 )
                {
                    tempPath = [[[[[openFolderPanel directory] \
                        stringByAppendingString: @"/"] \
                        stringByAppendingString: tempString] \
                        stringByAppendingString: \
                            [[NSNumber numberWithInt: y] stringValue]] \
                        stringByAppendingString: [[o_fileTypes objectAtIndex: \
                            [o_setup_fileFormat_pop indexOfSelectedItem]] \
                            objectAtIndex: 2]];
                    if(! [[NSFileManager defaultManager] fileExistsAtPath: tempPath] )
                        exit;
                    y = (y + 1);
                }*/
                NSLog( @"Warning: replacing existing file!" );
            }
            [imageSavingData writeToFile: tempPath atomically: YES];

            NSLog( [NSString stringWithFormat: @"processed file %i of %i", (x + 1), [o_files count]] );

            [currentImage release];
            x = (x + 1);
        }
        [o_prog_progBar incrementBy: 1];
        [o_prog_prog_lbl setStringValue: [NSString stringWithFormat: \
            @"%i of %i files", [[NSNumber numberWithDouble: [o_prog_progBar \
            doubleValue]] intValue], [[NSNumber numberWithDouble: \
            [o_prog_progBar maxValue]] intValue]]];
        [o_prog_prog_lbl display];
        [o_prog_progBar display];
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

        if( o_files )
            [o_files release];
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
    /* select the JPEG item */
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
