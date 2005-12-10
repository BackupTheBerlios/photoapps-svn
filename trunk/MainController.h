/*****************************************************************************
 * MainController.h: MainController class. Does everything atm.
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

#import <Cocoa/Cocoa.h>

@interface MainController : NSObject
{
    /* drop */
    IBOutlet id o_drop_imgVw;
    IBOutlet id o_drop_lbl;
    IBOutlet id o_drop_window;

    /* prog */
    IBOutlet id o_prog_cancel_btn;
    IBOutlet id o_prog_prog_lbl;
    IBOutlet id o_prog_progBar;
    IBOutlet id o_prog_stat_lbl;
    IBOutlet id o_prog_window;

    /* setup */
    IBOutlet id o_setup_cancel_btn;
    IBOutlet id o_setup_fileFormat_lbl;
    IBOutlet id o_setup_fileFormat_pop;
    IBOutlet id o_setup_fileFormat_longName_lbl;
    IBOutlet id o_setup_fileSize_lbl;
    IBOutlet id o_setup_fileSize_lbl_large;
    IBOutlet id o_setup_fileSize_lbl_small;
    IBOutlet id o_setup_fileSize_sld;
    IBOutlet id o_setup_ok_btn;
    IBOutlet id o_setup_window;
    
    NSOpenPanel * o_openPanel;
    NSSavePanel * o_savePanel;
    NSOpenPanel * openFolderPanel;
    NSArray * o_fileTypes;
    NSArray * o_files;
    BOOL setupWindowInited;
}

- (IBAction)dropAction:(id)sender;
- (IBAction)progCancel:(id)sender;
- (IBAction)setupCancel:(id)sender;
- (IBAction)setupFileFormatChanged:(id)sender;
- (IBAction)setupOkay:(id)sender;
- (IBAction)fileOpen:(id)sender;
- (IBAction)fileClose:(id)sender;
- (IBAction)fileNew:(id)sender;
- (IBAction)showLicense:(id)sender;

- (void)initSetupWindow;
- (void)processImages;
- (void)initArrays;
@end
