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

static MainController *_o_sharedMainInstance = nil;

+ (MainController *)sharedInstance
{
    return _o_sharedMainInstance ? _o_sharedMainInstance : [[self alloc] init];
}

- (id)init
{
    if( _o_sharedMainInstance) 
    {
        [self dealloc];
    } else {
        _o_sharedMainInstance = [super init];

        NSMutableDictionary * defaultPrefs = [NSMutableDictionary dictionary];
        
        [defaultPrefs setObject:[NSNumber numberWithInt:100] forKey: @"size"];
        [defaultPrefs setObject: @"JPEG" forKey: @"format"];
        
        o_prefs = [[NSUserDefaults standardUserDefaults] retain];
        [o_prefs registerDefaults: defaultPrefs];
    }

    return _o_sharedMainInstance;
}

- (void)dealloc
{
    if( o_openPanel )
        [o_openPanel release];
    if( openFolderPanel )
        [openFolderPanel release];
    [o_files release];
    [o_currentlyExportablefileTypes release];
    [o_useableImportFileTypes release];
    [o_prefs release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSArray * o_bmp;
    NSArray * o_gif;
    NSArray * o_jpeg;
    NSArray * o_png;
    NSArray * o_tiff;
    /* temp. arrays storing all properties of the respective file type in 
     * the order: public name, file suffix */
    o_bmp = [NSArray arrayWithObjects: @"BMP", @"bmp", nil];
    o_gif = [NSArray arrayWithObjects: @"GIF", @"gif", nil];
    o_jpeg = [NSArray arrayWithObjects: @"JPEG", @"jpg", nil];
    o_png = [NSArray arrayWithObjects: @"PNG", @"png", nil];
    o_tiff = [NSArray arrayWithObjects: @"TIFF", @"tif", nil];
    o_currentlyExportablefileTypes = [[NSArray alloc] initWithObjects: \
        o_bmp, o_gif, o_jpeg, o_png, o_tiff, nil];

    unsigned int x = 0;
    [o_setup_fileFormat_pop removeAllItems];
    while( x != [o_currentlyExportablefileTypes count] )
    {
        [o_setup_fileFormat_pop addItemWithTitle: \
        [[o_currentlyExportablefileTypes objectAtIndex: x] \
        objectAtIndex: 0]];
        x = (x + 1);
    }
    
    /* restore the settings from the last run */
    [o_setup_fileSize_sld setIntValue: [o_prefs integerForKey: @"size"]];
    [o_setup_fileFormat_pop selectItemWithTitle: \
        [o_prefs stringForKey: @"format"]];
}

- (void)setUseableImportFileTypes:(id)sentArray
{
    o_useableImportFileTypes = sentArray;
    [o_useableImportFileTypes retain];
}

- (id)getFiles
{
    return o_files;
}

- (void)setFiles:(id)sentArray
{
    o_files = sentArray;
    [o_files retain];
}

- (void)showSetup
{
    [o_setup_window makeKeyAndOrderFront:nil];
}

- (IBAction)setupCancel:(id)sender
{
    [o_setup_window close];
}

- (IBAction)setupOkay:(id)sender
{
    [o_setup_window close];

    /* save prefs */
    [o_prefs setObject: [NSNumber numberWithInt: \
        [o_setup_fileSize_sld intValue]] forKey: @"size"];
    [o_prefs setObject: [o_setup_fileFormat_pop titleOfSelectedItem] \
        forKey: @"format"];

    /* show progress window */
    [o_prog_stat_lbl setStringValue: NSLocalizedString(@"Waiting...", nil)];
    [o_prog_prog_lbl setStringValue: [NSString stringWithFormat: \
        NSLocalizedString(@"Image %i of %i", nil), 0, [o_files count]]];
    [o_prog_progBar setMaxValue: [o_files count]];
    [o_prog_progBar setDoubleValue: 0];
    [o_prog_window center];
    [o_prog_window makeKeyAndOrderFront: nil];

    /* show "save to" panel */
    SEL sel = @selector(savePanelDidEnd:returnCode:contextInfo:);
    openFolderPanel = [[NSOpenPanel alloc] init];
    [openFolderPanel setCanChooseDirectories: YES];
    [openFolderPanel setCanChooseFiles: YES];
    [openFolderPanel setResolvesAliases: YES];
    [openFolderPanel setAllowsMultipleSelection: NO];
    [openFolderPanel setTitle: NSLocalizedString(@"Choose Folder", nil)];
    [openFolderPanel setMessage: NSLocalizedString(@"Choose the folder to " \
        "save your shrunked file(s) to", nil)];
    [openFolderPanel setCanCreateDirectories: YES];
    [openFolderPanel setPrompt: NSLocalizedString(@"Select", nil)];
    [openFolderPanel beginForDirectory: nil file: nil types: [NSArray array] \
        modelessDelegate: self didEndSelector: sel contextInfo: nil];
}

- (void)savePanelDidEnd:(NSOpenPanel * )panel returnCode: (int)returnCode contextInfo: (void *)contextInfo
{
    if( returnCode == NSOKButton )
    {
        [openFolderPanel release];
        [self processImages];
    }
    else
    {
        [openFolderPanel release];
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
    BOOL exit = NO;
    NSString * tempString;
    NSString * tempPath;
    NSAutoreleasePool * o_pool;
    
    /* disable the indeterminate look and enable the threaded animation */
    [o_prog_stat_lbl setStringValue: 
        NSLocalizedString(@"Shrinking your images...", nil)];
    [o_prog_progBar setIndeterminate: NO];
    [o_prog_progBar setUsesThreadedAnimation: YES];
    [o_prog_window display];
    
    while( x != [o_files count] )
    {
        o_pool = [[NSAutoreleasePool alloc] init];

        currentImage = [[NSImage alloc] initWithContentsOfFile: \
            [o_files objectAtIndex: x]];
    
        imageRep = [currentImage bestRepresentationForDevice: nil];
        if (![imageRep isKindOfClass:[NSBitmapImageRep class]])
        {
            if( [o_files count] == 1 )
            {
                /* we are only processing one file, let's tell the user that his
                 * file is crap */
                NSRunAlertPanel( NSLocalizedString(@"Unsupported file type",nil)
                    , NSLocalizedString(@"The file you selected isn't " \
                    "supported by your version of QuickTime", nil), 
                    NSLocalizedString(@"OK", nil), nil, nil );
                return;
            } else {
                /* we are processing multiple files. don't confront the user
                 * with dozens of error messages and skip this crappy file */
                NSLog( [NSString stringWithFormat: @"skipped file %i", (x + 1)] );
                [currentImage release];
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
                NSRunAlertPanel( NSLocalizedString(@"Unsupported output " \
                    "file type", nil),
                    @"The file-format you selected isn't supported by this " \
                    "version of this application. This needs fixing. Please " \
                    "report that to the author(s).", @"OK", nil, nil );
                return;
            }

            /* check whether the file got an extension which needs to be 
             * stripped */
            if(! [[[NSFileManager defaultManager] fileAttributesAtPath:
                [o_files objectAtIndex: x] traverseLink: YES] objectForKey:
                NSFileExtensionHidden] )
            {
                tempString = [[NSFileManager defaultManager] \
                    displayNameAtPath: [o_files objectAtIndex: x]];
            }
            else
            {
                NSArray * tempArray = [[[NSFileManager defaultManager] \
                    displayNameAtPath: [o_files objectAtIndex: x]] \
                    componentsSeparatedByString: @"."];
                y = 0;
                tempString = @"";
                while( y != ([tempArray count] - 1) )
                {
                    if( y > 0 )
                    {
                        tempString = [tempString stringByAppendingFormat: 
                            @".%@", [tempArray objectAtIndex: y]];
                    }
                    else
                    {
                        tempString = [tempString stringByAppendingString:
                            [tempArray objectAtIndex: y]];
                    }
                    y = (y + 1);
                }
            }
            tempPath = [[openFolderPanel directory] 
                stringByAppendingFormat: @"/%@.%@", tempString,
                [[o_currentlyExportablefileTypes objectAtIndex:
                [o_setup_fileFormat_pop indexOfSelectedItem]] objectAtIndex: 1]];
                
            /* check whether a file exists yet and add an int to our name in 
             * that case */
            if( [[NSFileManager defaultManager] fileExistsAtPath: tempPath] )
            {
                y = 1;
                exit = NO;
                while( y < 10 && exit == NO )
                {
                    tempPath = [[openFolderPanel directory] \
                        stringByAppendingFormat: @"/%@.%i.%@", \
                        tempString, y, \
                        [[o_currentlyExportablefileTypes objectAtIndex: \
                            [o_setup_fileFormat_pop indexOfSelectedItem]] \
                            objectAtIndex: 1]];
                    if(! [[NSFileManager defaultManager] fileExistsAtPath: tempPath] )
                        exit = YES;
                    y = (y + 1);
                }
            }
            [imageSavingData writeToFile: tempPath atomically: YES];

            NSLog( [NSString stringWithFormat: @"processed file %i of %i", (x + 1), [o_files count]] );
        }
        [o_prog_progBar incrementBy: 1];
        [o_prog_prog_lbl setStringValue: [NSString stringWithFormat: \
            NSLocalizedString(@"Image %i of %i", nil), [[NSNumber \
            numberWithDouble: [o_prog_progBar doubleValue]] intValue], \
            [[NSNumber numberWithDouble: [o_prog_progBar maxValue]] intValue]]];
        [o_prog_prog_lbl display];
        [o_prog_progBar display];
        [currentImage release];
        [o_pool release];
        x = (x + 1);
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
        o_useableImportFileTypes modelessDelegate: self didEndSelector: sel \
        contextInfo: nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if( returnCode == NSOKButton )
    {
        if( o_files )
            [o_files release];
        o_files = [o_openPanel filenames];
        [o_files retain];
        [o_openPanel release];
        [self showSetup];
    } 
    else
    {
        [o_openPanel release];
    }
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
