/*****************************************************************************
 * SPADropImageView.h: custom class to accept file-drops
 * the code was inspired by the CocoaDragAndDrop sample code provided as 
 * public domain by Apple Computer, Inc.
 *****************************************************************************
 * Copyright (C) Felix KŸhne, 2005-2006
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

@interface SPADropImageView : NSImageView
{
    BOOL highlight; //highlight the drop zone
}

- (id)initWithCoder:(NSCoder *)coder;
@end
