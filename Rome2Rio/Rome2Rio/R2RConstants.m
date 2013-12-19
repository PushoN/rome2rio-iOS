//
//  R2RConstants.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RConstants.h"
#import "R2RKeys.h"

@interface R2RConstants()

@end

@implementation R2RConstants

+(id) alloc
{
    [NSException raise:@"R2RConstants is static" format:@"R2RConstants is static"];
    return nil;
}

+(NSString *) getUserId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userId = [userDefaults stringForKey:@"R2RUserID"];
    
    if (userId == NULL)
    {
        // if no userId generate a new one from
        // localeIdentifier + date + random number seeded from ID
        
        NSString *localeId = [[NSLocale currentLocale] localeIdentifier];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMddHHmmssSSS"];
        
        NSDate *now = [[NSDate alloc] init];
        
        NSString *theDate = [dateFormat stringFromDate:now];
        
        NSString *deviceUDID = NULL;
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)])
        {
            //get vendor UUID
            deviceUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        else
        {
            // pre 6.0 generate a UUID
            CFUUIDRef theUUID = CFUUIDCreate( kCFAllocatorDefault );
            CFStringRef theUUIDString = CFUUIDCreateString( kCFAllocatorDefault, theUUID );
            
            deviceUDID = (NSString *)CFBridgingRelease(theUUIDString);
            
            CFRelease(theUUID);
        }
        
        // using adler32 checksum as random seed
        NSInteger a = 1, b = 0;
        NSInteger const MOD_ADLER = 65521;
        for (NSInteger i = 0; i < [deviceUDID length]; i++)
        {
            a = (a + [deviceUDID characterAtIndex:i]) %MOD_ADLER;
            b = (b + a) % MOD_ADLER;
        }
        NSInteger adler = (b << 16) | a;
        
        srand(adler);
        NSInteger randNum = rand() % (9999 - 1000) + 1000;
        
        userId = [NSString stringWithFormat:(@"%@%@%d"),localeId, theDate, randNum];
        
        R2RLog(@"%@", userId);
        [userDefaults setObject:userId forKey:@"R2RUserID"];
    }
    
    return userId;
}

+(NSString *)getAppURL
{
    return [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", [R2RKeys getAppId]];
}

+(NSString *)getAppDescription
{
    return @"Discover how to get anywhere by plane, train, bus, ferry or car!";
}

+(UIImage *) getMasterViewBackgroundImage
{
    return [UIImage imageNamed:@"bg-retina"];
}

+(UIImage *) getMasterViewLogo
{
    return [UIImage imageNamed:@"r2r-retina"];
}


+(MKCoordinateRegion) getStartMapRegion
{
    //Region for Melbourne
//    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(-37.816022 , 144.96151);
//    return MKCoordinateRegionMakeWithDistance(startCoord , 50000, 50000);
    
    return MKCoordinateRegionForMapRect(MKMapRectWorld);
}

+(NSString *) getIconSpriteFileName
{
    return @"sprites6x2";
}

+(NSString *) getConnectionsImageFileName
{
    return @"ConnectionLines-v2";
}

+(NSString *) getMyLocationSpriteFileName
{
    return @"Blue_dot-24px";
}

//detail view icon
+(CGRect) getConnectionIconRect
{
    return CGRectMake(534, 92, 24, 24);
};

//annotation icon
+(CGRect) getHopIconRect
{
    return CGRectMake(540, 70, 18, 18);
};

+(CGRect) getMyLocationIconRect
{
    return CGRectMake(0, 0, 24, 24);
};

+(CGRect) getRouteFlightSpriteRect
{
    return CGRectMake(0, 160, 36, 36);
}

+(CGRect) getRouteTrainSpriteRect
{
    return CGRectMake(0, 196, 36, 36);
}

+(CGRect) getRouteBusSpriteRect
{
    return CGRectMake(0, 376, 36, 36);
}

+(CGRect) getRouteFerrySpriteRect
{
    return CGRectMake(0, 412, 36, 36);
}

+(CGRect) getRouteCarSpriteRect
{
    return CGRectMake(0, 304, 36, 36);
}

+(CGRect) getRouteWalkSpriteRect
{
    return CGRectMake(0, 448, 36, 36);
}

+(CGRect) getRouteUnknownSpriteRect
{
    return CGRectMake(0, 340, 36, 36);
}

+(CGRect) getResultFlightSpriteRect
{
    return CGRectMake(680, 120, 28, 24);
}

+(CGRect) getResultTrainSpriteRect
{
    return CGRectMake(708, 120, 38, 24);
}

+(CGRect) getResultBusSpriteRect
{
    return CGRectMake(768, 120, 36, 24);
}

+(CGRect) getResultFerrySpriteRect
{
    return CGRectMake(636, 120, 44, 24);
}

+(CGRect) getResultCarSpriteRect
{
    return CGRectMake(600, 120, 36, 24);
}

+(CGRect) getResultWalkSpriteRect
{
    return CGRectMake(804, 120, 28, 24);
}

+(CGRect) getResultUnknownSpriteRect
{
    return CGRectMake(746, 120, 22, 24);
}

+(UIColor *)getBackgroundColor
{
    return [UIColor colorWithRed:234.0/256.0 green:228.0/256.0 blue:224.0/256.0 alpha:1.0];
}

+(UIColor *)getExpandedCellColor
{
    return [UIColor colorWithRed:244.0/256.0 green:238.0/256.0 blue:234.0/256.0 alpha:1.0];
}

+(UIColor *)getCellColor
{
    return [UIColor colorWithRed:254.0/256.0 green:248.0/256.0 blue:244.0/256.0 alpha:1.0];
}

+(UIColor *)getDarkTextColor
{
    return [UIColor colorWithWhite:0.2 alpha:1.0];
}

+(UIColor *)getLightTextColor
{
    return [UIColor colorWithWhite:0.5 alpha:1.0];
}

+ (UIColor *)getButtonHighlightColor
{
    return [UIColor colorWithRed:242.0/256.0 green:103.0/256.0 blue:54.0/256.0 alpha:1.0];
}

+(UIColor *)getFlightLineColor
{
    return [UIColor colorWithRed:241/255.0 green:95/255.0 blue:34/255.0 alpha:0.8];
}

+(UIColor *)getBusLineColor
{
    return [UIColor colorWithRed:98/255.0 green:144/255.0 blue:46/255.0 alpha:0.8];
}

+(UIColor *)getTrainLineColor
{
    return [UIColor colorWithRed:35/255.0 green:99/255.0 blue:160/255.0 alpha:0.8];
}

+(UIColor *)getFerryLineColor
{
    return [UIColor colorWithRed:0/255.0 green:139/255.0 blue:174/255.0 alpha:0.8];
}

+(UIColor *)getDriveLineColor
{
    return [UIColor colorWithWhite:0.0 alpha:0.4];
}

+(UIColor *)getWalkLineColor
{
    return [UIColor colorWithRed:102/255.0 green:101/255.0 blue:100/255.0 alpha:0.8];
}

@end
