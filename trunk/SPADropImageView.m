/*****************************************************************************
 * SPADropImageView.m: custom class to accept file-drops
 * the code was inspired by the CocoaDragAndDrop sample code provided as 
 * public domain by Apple Computer, Inc.
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

#import "SPADropImageView.h"
#import "MainController.h"

@implementation SPADropImageView

- (id)initWithCoder:(NSCoder *)coder
{
    /* init method called for Interface Builder objects */

    if( self=[super initWithCoder: coder] )
    {
        //register for all the image types we can display
        [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
    }
    return self;
}

- (NSDragOperation)draggingEntered: (id <NSDraggingInfo>)sender
{
    /* method called whenever a drag enters our drop zone */
    
    /* Check if the pasteboard contains image data and source/user wants it copied */
        if ( [[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType] &&
             [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
             [sender draggingSourceOperationMask] &
             NSDragOperationCopy )
        {
            highlight = YES;                //highlight our drop zone
            [self setNeedsDisplay: YES];
            return NSDragOperationCopy;     //accept data as a copy operation
        }
    return NSDragOperationNone;
}

- (void)draggingExited: (id <NSDraggingInfo>)sender
{
    /* method called whenever a drag exits our drop zone */
    
    highlight = NO;                         //remove highlight of the drop zone
    [self setNeedsDisplay: YES];
}

-(void)drawRect: (NSRect)rect
{
    /* draw method is overridden to do drop highlighing */

    [super drawRect: rect];  //do the usual draw operation to display the image

    if( highlight )
    {
        //highlight by overlaying a gray border
        NSRect ourRect = rect;
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineJoinStyle: NSBevelLineJoinStyle];
        [NSBezierPath setDefaultLineWidth: 3];
        ourRect.origin.x = (rect.origin.x + 8);
        ourRect.origin.y = (rect.origin.y + 8);
        ourRect.size.width = (rect.size.width - 16);
        ourRect.size.height = (rect.size.height - 16);
        [NSBezierPath strokeRect: ourRect];
    }
}

- (BOOL)prepareForDragOperation: (id <NSDraggingInfo>)sender
{
    /* method to determine if we can accept the drop */

    highlight = NO;     //finished with the drag so remove any highlighting
    [self setNeedsDisplay: YES];
    
    /* check to see if we can accept the data */
    return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
} 

- (BOOL)performDragOperation: (id <NSDraggingInfo>)sender
{
    /* method that should handle the drop data */

    if([sender draggingSource]!=self)
    {
        [[MainController sharedInstance] setFiles: \
            [[sender draggingPasteboard] propertyListForType: NSFilenamesPboardType]];
        
        NSLog( [NSString stringWithFormat: @"received %i file(s)", 
            [[[MainController sharedInstance] getFiles] count]] );
        
        int x = 0;
        while( x != [[[MainController sharedInstance] getFiles] count] )
        {
            NSLog( [[[MainController sharedInstance] getFiles] objectAtIndex: x] );
            x = ( x + 1 );
        }
    }
    
    [[MainController sharedInstance] showSetup];
    
    return NO;
}

@end
