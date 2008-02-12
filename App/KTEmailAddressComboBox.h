//
//  KTEmailAddressComboBox.h
//  KTComponents
//
//  Copyright (c) 2005-2006, Karelia Software. All rights reserved.
//
//  THIS SOFTWARE IS PROVIDED BY KARELIA SOFTWARE AND ITS CONTRIBUTORS "AS-IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUR OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>


@interface KTEmailAddressComboBox : NSComboBox
{
	NSArray	*myActiveMailAccounts;
	NSString *myDefaultsAddressKey;
}

- (void)selectItemWithDefaultsKey:(NSString *)aKey;
- (void)saveSelectionToDefaults;

- (BOOL)addressIsAnonymous;

- (NSString *)address;
- (NSString *)addressViaDefaults;

- (NSString *)defaultsAddressKey;
- (void)setDefaultsAddressKey:(NSString *)aKey;

- (NSArray *)activeMailAccounts;
- (void)setActiveMailAccounts:(NSArray *)anActiveMailAccounts;


+ (NSString *)primaryEmailAddress;


// Hints for initialization
+ (void) setWillAddAnonymousEntry:(BOOL)anAnonymous;
+ (void) setWillIncludeNames:(BOOL)anIncludeNames;

@end
