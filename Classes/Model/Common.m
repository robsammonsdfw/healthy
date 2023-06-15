//
//  Common.m
//

#import "Common.h"
#include <sys/xattr.h>


BOOL isIPad()
{
  UIDevice *device = [UIDevice currentDevice];
  
  if ([device respondsToSelector:@selector(userInterfaceIdiom)])
  {
    UIUserInterfaceIdiom idiom = [device userInterfaceIdiom];
    switch (idiom) {
      case UIUserInterfaceIdiomPhone:
        return NO;
      case UIUserInterfaceIdiomPad:
        return YES;
      default:
        return NO;
    }
  }
    
  return NO;
}

BOOL isRetina() {
  if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] 
      && [[UIScreen mainScreen] scale] == 2)
    return YES;  ///< iPhone 4
  /// other devices
  return NO;
}

BOOL addSkipBackupAttributeToFile(NSString *filePath)
{
  const char *path = [filePath fileSystemRepresentation];
  const char *attrName = "com.apple.MobileBackup";
  u_int8_t attrValue = 1;
  
  int result = setxattr(path, attrName, &attrValue, sizeof(attrValue), 0, 0);
  return result == 0;
}

NSString *criticalDataPath()
{
  NSString *path = [LibraryPath 
                    stringByAppendingPathComponent:@"Private Documents/CriticalData"];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path 
                              withIntermediateDirectories:YES 
                                               attributes:nil 
                                                    error:&error];
    if (error) {
      DMLog(@"%@", [error localizedDescription]);
      return nil;
    }
  }
  return path;
}

NSString *offlineDataPath()
{
  NSString *path = [LibraryPath stringByAppendingPathComponent:
                    @"Private Documents/OfflineData"];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path 
                              withIntermediateDirectories:YES 
                                               attributes:nil 
                                                    error:&error];
    if (error) {
      DMLog(@"%@", [error localizedDescription]);
      return nil;
    }
    if (!addSkipBackupAttributeToFile(path))
      return nil;
  }
  return path;
}

id loadNib(Class aClass, NSString *nibName, id owner)
{
  NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:nibName 
                                                   owner:owner 
                                                 options:NULL];
  
  for (id niblet in niblets)
    if ([niblet isKindOfClass:aClass])
      return niblet;
  
  return nil;
}

id loadNibForCell(NSString *identifier, NSString *nibName, id owner)
{
  NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:nibName
                                                   owner:owner
                                                 options:NULL];
  
  for (UITableViewCell *cell in niblets)
    if ([cell.reuseIdentifier isEqualToString:identifier])
      return cell;
  
  return nil;
}

CGSize CGSizeScaledToFitSize(CGSize size1, CGSize size2)
{
  float w, h;
  
  float k1 = size1.height / size1.width;
  float k2 = size2.height / size2.width;
  
  if (k1 > k2) {
    w = roundf(size1.width * size2.height / size1.height);
    h = size2.height;
  } else {
    w = size2.width;
    h = roundf(size1.height * size2.width / size1.width);
  }
  return CGSizeMake(roundf(w), roundf(h));
}

CGSize CGSizeScaledToFillSize(CGSize size1, CGSize size2)
{
  float w, h;
  
  float k1 = size1.height / size1.width;
  float k2 = size2.height / size2.width;
  
  if (k1 > k2) {
    w = size2.width;
    h = roundf(size1.height * size2.width / size1.width);
  } else {
    w = roundf(size1.width * size2.height / size1.height);
    h = size2.height;
  }
  return CGSizeMake(roundf(w), roundf(h));
}

CGRect CGRectWithSize(CGSize size) {
  CGRect rect = CGRectZero;
  rect.size = size;
  return rect;
}

CGRect CGRectFillRect(CGRect rect1, CGRect rect2) {
  CGRect rect;
  rect.size = CGSizeScaledToFillSize(rect1.size, rect2.size);
  rect.origin.x = roundf(rect2.origin.x + 0.5 * (rect2.size.width - rect.size.width));
  rect.origin.y = roundf(rect2.origin.y + 0.5 * (rect2.size.height - rect.size.height));
  return rect;
}

CGRect CGRectExpandToLabel(UILabel *label)
{
  float result = 1.;
  
  float width = label.frame.size.width;
  
  if (label.text)
  {
      CGSize textSize = CGSizeMake(width, 1000000.);
      //      CGSize size = [label.text sizeWithFont:label.font
      //                           constrainedToSize:textSize
      //                               lineBreakMode:label.lineBreakMode];
      
      CGRect textRect = [label.text boundingRectWithSize:textSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:label.font}
                                                 context:nil];
      CGSize size = textRect.size;
      result = MAX(size.height, result);
  }
  
  return CGRectMake(label.frame.origin.x, label.frame.origin.y, width, result);
}

void ShowAlert(NSString *title, NSString *message)
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}









