//
//  BaseFormViewController.m
//  DEFWallet
//
//

#import "BaseFormViewController.h"

@interface BaseFormViewController ()

//cover view
@property(nonatomic, strong) UIView *coverView;

@property(nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;

@end

@implementation BaseFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCoverView];
}

- (void)setupCoverView {
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.backgroundColor = [UIColor clearColor];
    self.coverView.hidden = YES;
    [self.view addSubview:self.coverView];
    
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCoverViewTapEvent:)];
    [self.coverView addGestureRecognizer:self.gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma -
#pragma mark Events


/**
 Super Method, for clild class method extends
 */
- (IBAction)onEndOnExit:(id)sender {
}


/**
 Cover View Tap Event
 */
- (void)onCoverViewTapEvent:(UITapGestureRecognizer *)gesture {
    
    //hide keyboard
    [self onEndOnExit:nil];
    
    //hide cover view
    self.coverView.hidden = YES;
}

#pragma -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //when textfield begin editing,cover view will show
    self.coverView.hidden = NO;
}

@end
