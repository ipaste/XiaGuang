#import <Foundation/Foundation.h>

@protocol YTTransport <NSObject>

typedef enum {
    YTTransportUpward = 1,
    YTTransportDownward = 2,
    YTTransportBothWays = 3
} YTTransportType;

@property (nonatomic) YTTransportType type;

@end