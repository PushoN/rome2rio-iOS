//
//  R2RGetRoutes.m
//  HttpRequest
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Ash Verdoorn. All rights reserved.
//

#import "R2RSearch.h"

#import "R2RPrintSearch.h"

@interface R2RSearch() <R2RConnectionDelegate>

@property(strong, nonatomic) R2RConnection *r2rConnection;

@end


@implementation R2RSearch

@synthesize searchResponse;
@synthesize delegate;

-(id) initWithFromToStrings:(NSString *)fromString :(NSString *)toString delegate:(id<R2RSearchDelegate>)r2rSearchDelegate
{
    
    self = [super init];
    
    if (self != nil)
    {
        self.delegate = r2rSearchDelegate;
        	
        NSString *searchString = [NSString stringWithFormat:@"http://prototype.rome2rio.com/api/1.2/json/Search?key=wOAPMlcG&oName=%@&dName=%@", fromString, toString];
        
        NSString *searchEncoded = [searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        NSURL *searchUrl =  [NSURL URLWithString:searchEncoded];
        
        self.r2rConnection = [[R2RConnection alloc] initWithConnectionUrl:searchUrl delegate:self];
                
    }
    
    return self;
}


-(void) parseJson
{
    NSLog(@"Succeeded! Received %d bytes of data from GetRoutes",[self.r2rConnection.responseData length]);
    
    NSError *error = nil;
    
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:self.r2rConnection.responseData options:kNilOptions error:&error];
    
    // show all values/////////////////////////////
    for(id key in responseData) {
        
        id value = [responseData objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
    }/////////////////////////////////////////////
    
    
    self.searchResponse = [self parseResponse:responseData];
    
    ////set status to complete/resolved
    ////then call delegate for R2RViewController to set text box to place.Name;
    
    [self printTestData];
}

-(R2RSearchResponse*) parseResponse:(NSDictionary* )responseData
{
    R2RSearchResponse *parsedSearchResponse = [R2RSearchResponse alloc];
    
    parsedSearchResponse.airports = [self parseAirports:[responseData objectForKey:@"airports"]];
    parsedSearchResponse.airlines = [self parseAirlines:[responseData objectForKey:@"airlines"]];
    parsedSearchResponse.routes = [self parseRoutes:[responseData objectForKey:@"routes"]];
    
    return parsedSearchResponse;
    
}

-(NSMutableArray*) parseAirports:( NSArray *) airportsResponse
{
    NSMutableArray *airports = [[NSMutableArray alloc] initWithCapacity:[airportsResponse count]] ;
    
    for (id airportResponse in airportsResponse)
    {
        
        R2RAirport *airport = [self parseAirport:airportResponse];
        [airports addObject:airport];

    }
    
    return airports;
}

-(R2RAirport*) parseAirport:(id) airportResponse
{
    R2RAirport *airport = [R2RAirport alloc];
        
    airport.code = [airportResponse objectForKey:@"code"];
    airport.name = [airportResponse objectForKey:@"name"];
    
    NSString *positionString = [airportResponse objectForKey:@"pos"];
    
    airport.pos = [self parsePositionString:positionString];
    
    return airport;
}

-(R2RPosition*) parsePositionString:(NSString *) positionResponseString
{
    if ([positionResponseString length] == 0)
    {
        NSLog(@"%@", @"position nil or empty in parsePositionString");
        //R2RPosition *emptyPosition = [R2RPosition alloc];
        //return emptyPosition;
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:positionResponseString];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@","]];
    
    float lat,lng;
    [scanner scanFloat:&lat];
    [scanner scanFloat:&lng];
        
    R2RPosition *position = [self parsePosition:lat:lng];
    
    return  position;

}

-(NSMutableArray*) parsePositionArray:(NSString *) positionArrayString
{
    
    if ([positionArrayString length] == 0)
    {
        NSLog(@"%@", @"positionArray nil or empty in parsePositionArray");

        return nil;
    }
    
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    
    ///commented out while changes are made to API
//    NSScanner *scanner = [NSScanner scannerWithString:positionArrayString];
//    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@","]];
//    
//    while (![scanner isAtEnd])
//    {
//        float lat,lng;
//        [scanner scanFloat:&lat];
//        [scanner scanFloat:&lng];
//        
//        R2RPosition *position = [self parsePosition:lat:lng];
//        
//        [positions addObject:position];
//    }
    
    return positions;
    
}

-(R2RPosition*) parsePosition:(float) lat: (float) lng
{
    R2RPosition *position = [R2RPosition alloc];
    
    position.lat = lat;
    position.lng = lng;
    
    return  position;
    
}

-(NSMutableArray*) parseAirlines:( NSArray *) airlinesResponse
{
    NSMutableArray *airlines = [[NSMutableArray alloc] initWithCapacity:[airlinesResponse count]] ;
    
    for (id airlineResponse in airlinesResponse)
    {
        
        R2RAirline *airline = [self parseAirline:airlineResponse];
        [airlines addObject:airline];
        
    }
    
    return airlines;
}

-(R2RAirline*) parseAirline:(id) airlineResponse
{
    R2RAirline *airline = [R2RAirline alloc];
    
    airline.code = [airlineResponse objectForKey:@"code"];
    airline.name = [airlineResponse objectForKey:@"name"];
    airline.url = [airlineResponse objectForKey:@"url"];	
        
    NSLog(@"url\t%@", airline.url);
    
    return airline;
}

-(NSMutableArray*) parseRoutes: (NSArray *) routesResponse
{
    
    NSMutableArray *routes = [[NSMutableArray alloc] initWithCapacity:[routesResponse count]] ;
    
    for (id routeResponse in routesResponse)
    {
        
        R2RRoute *route = [self parseRoute:routeResponse];
        
        [routes addObject:route];
        
    }
    
    return routes;
    
}

-(R2RRoute*) parseRoute:(id) routeResponse
{
    R2RRoute *route = [R2RRoute alloc];
    
    route.name = [routeResponse objectForKey:@"name"];
    route.distance = [[routeResponse objectForKey:@"distance"] floatValue];
    route.duration = [[routeResponse objectForKey:@"duration"] floatValue];
    
    NSArray *stopsResponse = [routeResponse objectForKey:@"stops"];
    
    route.stops = [self parseStops:stopsResponse];
    
    NSArray *segmentsResponse = [routeResponse objectForKey:@"segments"];
    
    route.segments = [self parseSegments:segmentsResponse];
    
    return route;
    
}

-(NSMutableArray*) parseStops: (NSArray *) stopsResponse
{
    NSMutableArray *stops = [[NSMutableArray alloc] initWithCapacity:[stopsResponse count]];
    
    for (R2RStop *stopResponse in stopsResponse)
    {
        R2RStop *stop = [self parseStop:stopResponse];
        
        [stops addObject:stop];
    }
    
    return stops;
}

-(R2RStop*) parseStop:(id) stopResponse
{
    R2RStop *stop = [R2RStop alloc];
    
    stop.name = [stopResponse objectForKey:@"name"];
    
    NSString *posString = [stopResponse objectForKey:@"pos"];
    stop.pos = [self parsePositionString:posString];
    
    stop.kind = [stopResponse objectForKey:@"kind"];
    stop.code = [stopResponse objectForKey:@"code"];
    
    return stop;
}

-(NSMutableArray*) parseSegments: (NSArray *) segmentsResponse
{
    NSMutableArray *segments = [[NSMutableArray alloc] initWithCapacity:[segmentsResponse count]];
    
    for (id segmentResponse in segmentsResponse)
    {
        NSString *kind = [segmentResponse objectForKey:@"kind"];
        
        id segment;
        
        if ([kind isEqualToString:@"walk"] || [kind isEqualToString:@"car"])
        {
            segment = [self parseWalkDriveSegment:segmentResponse];
        }
        else if ([kind isEqualToString:@"train"] || [kind isEqualToString:@"bus"] || [kind isEqualToString:@"ferry"])
        {
            segment = [self parseTransitSegment:segmentResponse];
        }
        else if ([kind isEqualToString:@"flight"])
        {
            segment = [self parseFlightSegment:segmentResponse];
        }
        else            
        {
            //////////////////////////////////
            NSLog(@"unknown segment kind or error%@", @"." );
            //////////////////////////////////
        }
        
        [segments addObject:segment];
        
    }
    
    return segments;
}

-(R2RWalkDriveSegment*) parseWalkDriveSegment: (NSDictionary *) segmentResponse
{
    R2RWalkDriveSegment *segment = [R2RWalkDriveSegment alloc];
    
    segment.kind = [segmentResponse objectForKey:@"kind"];
    segment.distance = [[segmentResponse objectForKey:@"distance"] floatValue];
    segment.duration = [[segmentResponse objectForKey:@"duration"] floatValue];
    segment.sName = [segmentResponse objectForKey:@"sName"];
    
    NSString *sPosString = [segmentResponse objectForKey:@"sPos"];
    segment.sPos = [self parsePositionString:sPosString];
    
    segment.tName = [segmentResponse objectForKey:@"tName"];
    
    NSString *tPosString = [segmentResponse objectForKey:@"tPos"];
    segment.tPos = [self parsePositionString:tPosString];
    
    return segment;
}

-(R2RTransitSegment*) parseTransitSegment: (NSDictionary *) segmentResponse
{
    R2RTransitSegment *segment = [R2RTransitSegment alloc];
    
    segment.kind = [segmentResponse objectForKey:@"kind"];
    segment.distance = [[segmentResponse objectForKey:@"distance"] floatValue];
    segment.duration = [[segmentResponse objectForKey:@"duration"] floatValue];
    segment.sName = [segmentResponse objectForKey:@"sName"];
    
    NSString *sPosString = [segmentResponse objectForKey:@"sPos"];
    segment.sPos = [self parsePositionString:sPosString];
    
    segment.tName = [segmentResponse objectForKey:@"tName"];
    
    NSString *tPosString = [segmentResponse objectForKey:@"tPos"];
    segment.tPos = [self parsePositionString:tPosString];
    
    NSArray *itinerariesResponse = [segmentResponse objectForKey:@"itineraries"];
    
    segment.itineraries = [self parseTransitItineraries:itinerariesResponse];
    
    return segment;
}

-(NSMutableArray*) parseTransitItineraries:(NSArray *) itinerariesResponse
{
    NSMutableArray *transitItineraries = [[NSMutableArray alloc] initWithCapacity:[itinerariesResponse count]] ;
    
    for (id transitItineraryResponse in itinerariesResponse)
    {
        
        R2RTransitItinerary *transitItinerary = [self parseTransitItinerary:transitItineraryResponse];
        
        [transitItineraries addObject:transitItinerary];
        
    }
    
    return transitItineraries;
}

-(R2RTransitItinerary*) parseTransitItinerary:(NSDictionary *) transitItineraryResponse
{
    R2RTransitItinerary *transitItinerary = [R2RTransitItinerary alloc];
    
    NSArray *transitLegsResponse = [transitItineraryResponse objectForKey:@"legs"];
    
    transitItinerary.legs = [self parseTransitLegs:transitLegsResponse];
    
    return  transitItinerary;
}

-(NSMutableArray*) parseTransitLegs:(NSArray *) transitLegsResponse
{
    NSMutableArray *transitLegs = [[NSMutableArray alloc] initWithCapacity:[transitLegsResponse count]];
    
    for (id transitLegResponse in transitLegsResponse)
    {
        R2RTransitLeg *transitLeg = [self parseTransitLeg:transitLegResponse];
        
        [transitLegs addObject:transitLeg];
    }
    
    return transitLegs;
}

-(R2RTransitLeg*) parseTransitLeg:(NSDictionary *) transitLegResponse
{
    R2RTransitLeg *transitLeg = [R2RTransitLeg alloc];
    
    transitLeg.url = [transitLegResponse objectForKey:@"url"];
    
    NSArray *transitHopsResponse = [transitLegResponse objectForKey:@"hops"];
    
    transitLeg.hops = [self parseTransitHops:transitHopsResponse];
    
    return transitLeg;
}

-(NSMutableArray*) parseTransitHops:(NSArray *) transitHopsResponse
{
    NSMutableArray *transitHops = [[NSMutableArray alloc] initWithCapacity:[transitHopsResponse count]];
    
    for (id transitHopResponse in transitHopsResponse)
    {
        R2RTransitHop *transitHop = [self parseTransitHop:transitHopResponse];
        
        [transitHops addObject:transitHop];
    }
    
    return transitHops;
}

-(R2RTransitHop*) parseTransitHop:(NSDictionary *) transitHopResponse
{
    R2RTransitHop *transitHop = [R2RTransitHop alloc];
    
    transitHop.sName = [transitHopResponse objectForKey:@"sName"];
    
    NSString *sPosString = [transitHopResponse objectForKey:@"sPos"];
    transitHop.sPos = [self parsePositionString:sPosString];
    
    transitHop.tName = [transitHopResponse objectForKey:@"tName"];
    
    NSString *tPosString = [transitHopResponse objectForKey:@"tPos"];
    transitHop.tPos = [self parsePositionString:tPosString];
    
    transitHop.vehicle = [transitHopResponse objectForKey:@"vehicle"];
    transitHop.line = [transitHopResponse objectForKey:@"line"];
    transitHop.frequency = [transitHopResponse objectForKey:@"frequency"];
    transitHop.duration = [[transitHopResponse objectForKey:@"duration"] floatValue];
    transitHop.agency = [transitHopResponse objectForKey:@"agency"];
    
    NSString *pathPostionArrayString = [transitHopResponse objectForKey:@"path"];
    
    transitHop.path = [self parsePositionArray:pathPostionArrayString];
    
    return transitHop;
}

-(R2RFlightSegment*) parseFlightSegment: (NSDictionary *) segmentResponse
{
    R2RFlightSegment *segment = [R2RFlightSegment alloc];
    
    segment.kind = [segmentResponse objectForKey:@"kind"];
    segment.distance = [[segmentResponse objectForKey:@"distance"] floatValue];
    segment.duration = [[segmentResponse objectForKey:@"duration"] floatValue];
    segment.sCode = [segmentResponse objectForKey:@"sCode"];
    segment.tCode = [segmentResponse objectForKey:@"tCode"];
    
    NSArray *itinerariesResponse = [segmentResponse objectForKey:@"itineraries"];
    
    segment.itineraries = [self parseFlightItineraries:itinerariesResponse];
    
    return segment;
}

-(NSMutableArray*) parseFlightItineraries:(NSArray *) itinerariesResponse
{
    NSMutableArray *flightItineraries = [[NSMutableArray alloc] initWithCapacity:[itinerariesResponse count]] ;
    
    for (id flightItineraryResponse in itinerariesResponse)
    {
        
        R2RFlightItinerary *flightItinerary = [self parseFlightItinerary:flightItineraryResponse];
        
        [flightItineraries addObject:flightItinerary];
        
    }
    
    return flightItineraries;
}

-(R2RFlightItinerary*) parseFlightItinerary:(NSDictionary *) flightItineraryResponse
{
    R2RFlightItinerary *flightItinerary = [R2RFlightItinerary alloc];
    
    NSArray *flightLegsResponse = [flightItineraryResponse objectForKey:@"legs"];
    
    flightItinerary.legs = [self parseFlightLegs:flightLegsResponse];
    
    NSArray *flightTicketSetsResponse = [flightItineraryResponse objectForKey:@"ticketSets"];
    
    flightItinerary.ticketSets = [self parseFlightTicketSets:flightTicketSetsResponse];
    
    return flightItinerary;
}

-(NSMutableArray*) parseFlightLegs:(NSArray *) flightLegsResponse
{
    NSMutableArray *flightLegs = [[NSMutableArray alloc] initWithCapacity:[flightLegsResponse count]];
    
    for (id flightLegResponse in flightLegsResponse)
    {
        R2RFlightLeg *flightLeg = [self parseFlightLeg:flightLegResponse];
        
        [flightLegs addObject:flightLeg];
    }
    
    return flightLegs;
}

-(R2RFlightLeg*) parseFlightLeg:(NSDictionary *) flightLegResponse
{
    R2RFlightLeg *flightLeg = [R2RFlightLeg alloc];
    
    NSArray *flightHopsResponse = [flightLegResponse objectForKey:@"hops"];
    
    flightLeg.hops = [self parseFlightHops:flightHopsResponse];
    
    return flightLeg;
}

-(NSMutableArray*) parseFlightHops:(NSArray *) flightHopsResponse
{
    NSMutableArray *flightHops = [[NSMutableArray alloc] initWithCapacity:[flightHopsResponse count]];
    
    for (id flightHopResponse in flightHopsResponse)
    {
        R2RFlightHop *flightHop = [self parseFlightHop:flightHopResponse];
        
        [flightHops addObject:flightHop];
    }
    
    return flightHops;
}

-(R2RFlightHop*) parseFlightHop:(NSDictionary *) flightHopResponse
{
    R2RFlightHop *flightHop = [R2RFlightHop alloc];
    
    flightHop.sCode = [flightHopResponse objectForKey:@"sCode"];
    flightHop.tCode = [flightHopResponse objectForKey:@"tCode"];
    flightHop.sTime = [[flightHopResponse objectForKey:@"sTime"] floatValue];
    flightHop.tTime = [[flightHopResponse objectForKey:@"tTime"] floatValue];
    flightHop.airline = [flightHopResponse objectForKey:@"airline"];
    flightHop.flight = [flightHopResponse objectForKey:@"flight"];
    flightHop.duration = [[flightHopResponse objectForKey:@"duration"] floatValue];
    flightHop.dayChange = [[flightHopResponse objectForKey:@"dayChange"] intValue];
    flightHop.lDuration = [[flightHopResponse objectForKey:@"lDuration"] floatValue];
    flightHop.lDayChange = [[flightHopResponse objectForKey:@"lDayChange"] intValue];
    
    return flightHop;
}

-(NSMutableArray*) parseFlightTicketSets:(NSArray *) flightTicketSetsResponse
{
    NSMutableArray *flightTicketSets = [[NSMutableArray alloc] initWithCapacity:[flightTicketSetsResponse count]];
    
    for (id flightTicketSetResponse in flightTicketSetsResponse)
    {
        R2RFlightTicketSet *flightTicketSet = [self parseFlightTicketSet:flightTicketSetResponse];
        
        [flightTicketSets addObject:flightTicketSet];
    }
    
    return flightTicketSets;
}

-(R2RFlightTicketSet*) parseFlightTicketSet:(NSDictionary *) flightTicketSetResponse
{
    R2RFlightTicketSet *flightTicketSet = [R2RFlightTicketSet alloc];
    
    flightTicketSet.sCode = [flightTicketSetResponse objectForKey:@"sCode"];
    flightTicketSet.tCode = [flightTicketSetResponse objectForKey:@"tCode"];
    
    NSArray *flightTicketsResponse = [flightTicketSetResponse objectForKey:@"tickets"];
    
    flightTicketSet.tickets = [self parseFlightTickets:flightTicketsResponse];
    
    return flightTicketSet;
}

-(NSMutableArray*) parseFlightTickets:(NSArray *) flightTicketsResponse
{
    NSMutableArray *flightTickets = [[NSMutableArray alloc] initWithCapacity:[flightTicketsResponse count]];
    
    for (id flightTicketResponse in flightTicketsResponse)
    {
        R2RFlightTicket *flightTicket = [self parseFlightTicket:flightTicketResponse];
        
        [flightTickets addObject:flightTicket];
    }
    
    return flightTickets;
}

-(R2RFlightTicket*) parseFlightTicket:(NSDictionary *) flightTicketResponse
{
    R2RFlightTicket *flightTicket = [R2RFlightTicket alloc];
    
    flightTicket.name = [flightTicketResponse objectForKey:@"name"];
    flightTicket.price = [[flightTicketResponse objectForKey:@"price"] floatValue];
    flightTicket.currency = [flightTicketResponse objectForKey:@"currency"];
    flightTicket.message = [flightTicketResponse objectForKey:@"message"];
    flightTicket.url = [flightTicketResponse objectForKey:@"url"];
    
    return flightTicket;
}

- (void) R2RConnectionProcessData:(R2RConnection *) delegateConnection
{
    [self parseJson];
    
    [[self delegate] R2RSearchResolved:self];
    ////set status to complete/resolved
    ////then call delegate for R2RViewController to inform of earch completion
    
}


-(void) printTestData
{
    R2RPrintSearch *printSearch = [R2RPrintSearch alloc];
    
    [printSearch printSearchData:self.searchResponse];
    
    
}

@end
