//
//  Common.m
//

#import "Common.h"
#include <sys/xattr.h>

id loadNib(Class aClass, NSString *nibName, id owner) {
  NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:nibName 
                                                   owner:owner 
                                                 options:NULL];
  
  for (id niblet in niblets)
    if ([niblet isKindOfClass:aClass])
      return niblet;
  
  return nil;
}

id loadNibForCell(NSString *identifier, NSString *nibName, id owner) {
  NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:nibName
                                                   owner:owner
                                                 options:NULL];
  
  for (UITableViewCell *cell in niblets)
    if ([cell.reuseIdentifier isEqualToString:identifier])
      return cell;
  
  return nil;
}
