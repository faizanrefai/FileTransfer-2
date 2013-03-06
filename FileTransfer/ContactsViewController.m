//
//  ContactsViewController.m
//  FileTransfer
//
//  Created by i Tech Coders Pvt Ltd. on 12/12/12.
//
//

#import "ContactsViewController.h"
#import "ContactsDetailViewController.h"
@interface ContactsViewController ()

@end

@implementation ContactsViewController
@synthesize contactsArray,contacts;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    // assigning control back to the main controller
	[self dismissModalViewControllerAnimated:YES];
}
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    // Get the first and the last name. Actually, copy their values using the person object and the appropriate
    // properties into two string variables equivalently.
    // Watch out the ABRecordCopyValue method below. Also, notice that we cast to NSString *.
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    // Compose the full name.
    NSString *fullName = @"";
    // Before adding the first and the last name in the fullName string make sure that these values are filled in.
    if (firstName != nil) {
        fullName = [fullName stringByAppendingString:firstName];
    }
    if (lastName != nil) {
        fullName = [fullName stringByAppendingString:@" "];
        fullName = [fullName stringByAppendingString:lastName];
    }
    
    
    // Get the multivalue e-mail property.
    CFTypeRef multivalue = ABRecordCopyValue(person, property);
    
    // Get the index of the selected e-mail. Remember that the e-mail multi-value property is being returned as an array.
    CFIndex index = ABMultiValueGetIndexForIdentifier(multivalue, identifier);
    
    // Copy the e-mail value into a string.
    NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multivalue, index);
    
    // Create a temp array in which we'll add all the desired values.
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:fullName];
    
    // Save the email into the tempArray array.
    [tempArray addObject:email];
    
    
    // Now add the tempArray into the contactsArray.
    [contactsArray addObject:tempArray];
    
    // Release the tempArray.
    
    
    // Reload the table to display the new data.
    //    [table reloadData];
    
    // Dismiss the contacts view controller.
    [contacts dismissModalViewControllerAnimated:YES];
    
    
	return NO;
}
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    contactsArray=[[NSMutableArray alloc]init];
    ABRecordRef ref;
    ABAddressBookRef m_addressbook = ABAddressBookCreate();
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
    CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
    NSLog(@" n people count values %ld",nPeople);
    
    for (int i=0; i<nPeople; i++)
    {
        NSMutableArray *contactOfAPerson = [[NSMutableArray alloc] init];
        ref = CFArrayGetValueAtIndex(allPeople,i);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSMutableArray *phonearray = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonPhoneProperty);
       
        // Compose the full name.
        NSString *fullName = @"";
        // Before adding the first and the last name in the fullName string make sure that these values are filled in.
        if (firstName != nil) {
            fullName = [fullName stringByAppendingString:firstName];
        }
        if (lastName != nil) {
            fullName = [fullName stringByAppendingString:@" "];
            fullName = [fullName stringByAppendingString:lastName];
        }
       NSString* ffullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        [contactOfAPerson addObject:fullName];
        //[contactOfAPerson setPhoneNumber:(NSString *)ABRecordCopyValue(ref, kABPersonPhoneMobileLabel)];
        [contactsArray addObject:fullName];
    }
    NSLog(@"%@",contactsArray);
    CFRelease(ref);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%@",[contactsArray objectAtIndex:indexPath.row]];
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    ContactsDetailViewController *friendListViewController = [[ContactsDetailViewController alloc] init];

    friendListViewController.contactsArray=[NSString stringWithFormat:@"%@",[contactsArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:friendListViewController animated:YES];
}

@end
