//
// Atlas Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "TileMapTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {	
			@"TMXIsoZorder",
			@"TMXOrthoZorder",
			@"TMXIsoVertexZ",
			@"TMXOrthoVertexZ",	
			@"TMXOrthoTest",
			@"TMXOrthoTest2",
			@"TMXOrthoTest3",
			@"TMXOrthoTest4",
			@"TMXIsoTest",
			@"TMXIsoTest1",
			@"TMXIsoTest2",
			@"TMXUncompressedTest",
			@"TMXHexTest",
			@"TMXDynamicHexTest",
			@"TMXReadWriteTest",
			@"TMXTilesetTest",
			@"TMXOrthoObjectsTest",
			@"TMXIsoObjectsTest",
			@"TMXTilePropertyTest",
			@"TMXResizeTest",
			@"TMXIsoMoveLayer",
			@"TMXOrthoMoveLayer",

			@"TileMapTest",
			@"TileMapEditTest",
};

enum {
	kTagTileMap = 1,
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark -
#pragma mark TileDmo

@implementation TileDemo
-(id) init
{
	if( (self=[super init] )) {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif

		CGSize s = [self.director winSize];
			
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];	
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [self.director convertToGL: touchLocation];
	prevLocation = [self.director convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	
	CCNode *node = [self getChildByTag:kTagTileMap];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CCNode *node = [self getChildByTag:kTagTileMap];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, CGPointMake( event.deltaX, -event.deltaY) )];

	return YES;
}
#endif

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[self.director replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[self.director replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[self.director replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
-(NSString*) subtitle
{
	return @"drag the screen";
}
@end


#pragma mark -
#pragma mark TileMapTest

@implementation TileMapTest
-(id) init
{
	if( (self=[super init]) ) {
	
		
		CCTileMapAtlas *map = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];
		// Convert it to "anti alias" (GL_LINEAR filtering)
		[map.texture setAntiAliasTexParameters];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// If you are not going to use the Map, you can free it now
		// NEW since v0.7
		[map releaseMap];
		
		[self addChild:map z:0 tag:kTagTileMap];
		
		map.anchorPoint = ccp(0, 0.5f);
		
		CCScaleBy *scale = [CCScaleBy actionWithDuration:4 scale:0.8f];
		CCActionInterval *scaleBack = [scale reverse];
		
		id seq = [CCSequence actions: scale,
								scaleBack,
								nil];
		
		[map runAction:[CCRepeatForever actionWithAction:seq]];
	}
	
	return self;
}

-(NSString *) title
{
	return @"TileMapAtlas";
}

@end

#pragma mark -
#pragma mark TileMapEditTest

@implementation TileMapEditTest
-(id) init
{
	if( (self=[super init]) ) {
		
		
		CCTileMapAtlas *map = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];

		// Create an Aliased Atlas
		[map.texture setAliasTexParameters];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// If you are not going to use the Map, you can free it now
		// [tilemap releaseMap];
		// And if you are going to use, it you can access the data with:
		[self schedule:@selector(updateMap:) interval:0.2f];
		
		[self addChild:map z:0 tag:kTagTileMap];
		
		map.anchorPoint = ccp(0, 0);
		map.position = ccp(-20,-200);
	}	
	return self;
}

-(void) updateMap:(ccTime) dt
{
	// IMPORTANT
	//   The only limitation is that you cannot change an empty, or assign an empty tile to a tile
	//   The value 0 not rendered so don't assign or change a tile with value 0

	CCTileMapAtlas *tilemap = (CCTileMapAtlas*) [self getChildByTag:kTagTileMap];
	
	//
	// For example you can iterate over all the tiles
	// using this code, but try to avoid the iteration
	// over all your tiles in every frame. It's very expensive
	//	for(int x=0; x < tilemap.tgaInfo->width; x++) {
	//		for(int y=0; y < tilemap.tgaInfo->height; y++) {
	//			ccColor3B c =[tilemap tileAt:ccg(x,y)];
	//			if( c.r != 0 ) {
	//				NSLog(@"%d,%d = %d", x,y,c.r);
	//			}
	//		}
	//	}
	
	// NEW since v0.7
	ccColor3B c =[tilemap tileAt:ccg(13,21)];		
	c.r++;
	c.r %= 50;
	if( c.r==0)
		c.r=1;
	
	// NEW since v0.7
	[tilemap setTile:c at:ccg(13,21)];			
	
}

-(NSString *) title
{
	return @"Editable TileMapAtlas";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest

@implementation TMXOrthoTest

-(id) init
{
	if( (self=[super init]) ) {
		
		//
		// Test orthogonal with 3d camera and anti-alias textures
		//
		// it should not flicker. No artifacts should appear
		//

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		
		float x, y, z;
		[[map camera] eyeX:&x eyeY:&y eyeZ:&z];
		[[map camera] setEyeX:x-200 eyeY:y eyeZ:z+300];		
	}	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	[self.director setProjection:kCCDirectorProjection3D];
}

-(void) onExit
{
	[self.director setProjection:kCCDirectorProjection2D];
	[super onExit];
}


-(NSString *) title
{
	return @"TMX Orthogonal test";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest2

@implementation TMXOrthoTest2
-(id) init
{
	if( (self=[super init]) ) {		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		[map runAction:[CCScaleBy actionWithDuration:2 scale:0.5f]];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Ortho test2";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest3

@implementation TMXOrthoTest3
-(id) init
{
	if( (self=[super init]) ) {		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test3.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		
		[map setScale:0.2f];
		[map setAnchorPoint:ccp(0.5f, 0.5f)];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX anchorPoint test";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest4

@implementation TMXOrthoTest4
-(id) init
{
	if( (self=[super init]) ) {		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test4.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s1 = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s1.width,s1.height);
		
		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		
		[map setAnchorPoint:ccp(0, 0)];

		CCTMXLayer *layer = [map layerNamed:@"Layer 0"];
		CGSize s = [layer layerSize];
		
		CCSprite *sprite;
		sprite = [layer tileAt:ccp(0,0)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(s.width-1,0)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(0,s.height-1)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(s.width-1,s.height-1)];
		[sprite setScale:2];
		
		[self schedule:@selector(removeSprite:) interval:2];
	}	
	return self;
}

-(void) removeSprite:(ccTime)dt
{
	[self unschedule:_cmd];

	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = [map layerNamed:@"Layer 0"];
	CGSize s = [layer layerSize];

	CCSprite *sprite = [layer tileAt:ccp(s.width-1,0)];
	[layer removeChild:sprite cleanup:YES];
}

-(NSString *) title
{
	return @"TMX width/height test";
}
@end



#pragma mark -
#pragma mark TMXIsoTest

@implementation TMXIsoTest
-(id) init
{
	if( (self=[super init]) ) {
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];		
		
		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[CCMoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test 0";
}
@end

#pragma mark -
#pragma mark TMXIsoTest1

@implementation TMXIsoTest1
-(id) init
{
	if( (self=[super init]) ) {
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		[map setAnchorPoint:ccp(0.5f, 0.5f)];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test + anchorPoint";
}
@end

#pragma mark -
#pragma mark TMXIsoTest2

@implementation TMXIsoTest2
-(id) init
{
	if( (self=[super init]) ) {
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];	
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[CCMoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test 2";
}
@end

@implementation TMXUncompressedTest
-(id) init
{
	if( (self=[super init]) ) {
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test2-uncompressed.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];	
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[CCMoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];
		
		// testing release map
		for( CCTMXLayer *layer in [map children])
			[layer releaseMap];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Uncompressed test";
}
@end


#pragma mark -
#pragma mark TMXHexTest

@implementation TMXHexTest
-(id) init
{
	if( (self=[super init]) ) {
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/hexa-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Hex test";
}
@end


#pragma mark -
#pragma mark TMXDynamicHexTest

#import <zlib.h>

@implementation TMXDynamicHexTest
- (NSData *)gzipDeflateData:(NSData *)data
{
	if ([data length] == 0) return data;
	
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[data bytes];
	strm.avail_in = [data length];
	
	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
	
	do {
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = [compressed mutableBytes] + strm.total_out;
		strm.avail_out = [compressed length] - strm.total_out;
		
		deflate(&strm, Z_FINISH);  
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return [NSData dataWithData:compressed];
}

//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

char *NewBase64Encode(
					  const void *buffer,
					  size_t length,
					  bool separateLines,
					  size_t *outputLength)
{
	const unsigned char *inputBuffer = (const unsigned char *)buffer;
	
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4
	
	//
	// Byte accurate calculation of final buffer size
	//
	size_t outputBufferSize =
	((length / BINARY_UNIT_SIZE)
	 + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
	* BASE64_UNIT_SIZE;
	if (separateLines)
	{
		outputBufferSize +=
		(outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
	}
	
	//
	// Include space for a terminating zero
	//
	outputBufferSize += 1;
	
	//
	// Allocate the output buffer
	//
	char *outputBuffer = (char *)malloc(outputBufferSize);
	if (!outputBuffer)
	{
		return NULL;
	}
	
	size_t i = 0;
	size_t j = 0;
	const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
	size_t lineEnd = lineLength;
	
	while (true)
	{
		if (lineEnd > length)
		{
			lineEnd = length;
		}
		
		for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
		{
			//
			// Inner loop: turn 48 bytes into 64 base64 characters
			//
			outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
			outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
												   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
			outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
												   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
			outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
		}
		
		if (lineEnd == length)
		{
			break;
		}
		
		//
		// Add the newline
		//
		outputBuffer[j++] = '\r';
		outputBuffer[j++] = '\n';
		lineEnd += lineLength;
	}
	
	if (i + 1 < length)
	{
		//
		// Handle the single '=' case
		//
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
											   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
		outputBuffer[j++] =	'=';
	}
	else if (i < length)
	{
		//
		// Handle the double '=' case
		//
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
		outputBuffer[j++] = '=';
		outputBuffer[j++] = '=';
	}
	outputBuffer[j] = 0;
	
	//
	// Set the output length and return the buffer
	//
	if (outputLength)
	{
		*outputLength = j;
	}
	return outputBuffer;
}

- (NSString *)base64EncodedStringWithData:(NSData *)data
{
	size_t outputLength;
	char *outputBuffer =
	NewBase64Encode([data bytes], [data length], true, &outputLength);
	
	NSString *result =
	[[[NSString alloc]
	  initWithBytes:outputBuffer
	  length:outputLength
	  encoding:NSASCIIStringEncoding]
	 autorelease];
	free(outputBuffer);
	return result;
}

-(id) init
{
	if( (self=[super init]) ) {
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		//create tmx
		NSMutableString * tmx = [NSMutableString string];
		[tmx appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
		[tmx appendFormat:@"<map version=\"1.0\" orientation=\"hexagonal\" width=\"5\" height=\"5\" tilewidth=\"175\" tileheight=\"150\">"];
		[tmx appendFormat:@"<tileset firstgid=\"1\" name=\"bla\" tilewidth=\"175\" tileheight=\"150\">"];
		[tmx appendFormat:@"<image source=\"%@\"/>", [[NSBundle mainBundle] pathForResource:@"TileMaps/hexa-tiles.png" ofType:nil]];//using absolute path for images
		[tmx appendFormat:@"</tileset>"];
		[tmx appendFormat:@"<layer name=\"Layer 0\" width=\"5\" height=\"5\">"];
		[tmx appendFormat:@"<data encoding=\"base64\" compression=\"gzip\">"];
		
		UInt32 * data = calloc(25, sizeof(UInt32));
		for (int i = 0; i < 25; i++) {
			data[i] = arc4random()%6+1;
		}
		NSData * dataObject = [NSData dataWithBytes:data length:25*sizeof(UInt32)];
		NSData * compressedData = [self gzipDeflateData:dataObject];
		NSString * encodedData = [self base64EncodedStringWithData:compressedData];
		[tmx appendFormat:@"%@", encodedData];
		
		[tmx appendFormat:@"</data>"];
		[tmx appendFormat:@"</layer>"];
		[tmx appendFormat:@"</map>"];
		
		NSData * tmxData = [tmx dataUsingEncoding:NSUTF8StringEncoding];
		
		//use file
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXData:tmxData];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Dynamic Hex test";
}
@end

#pragma mark -
#pragma mark TMXReadWriteTest

@implementation TMXReadWriteTest
-(id) init
{
	if( (self=[super init]) ) {

		gid = 0;
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		
		CCTMXLayer *layer = [map layerNamed:@"Layer 0"];
		[layer.texture setAntiAliasTexParameters];
		
		map.scale = 1;

		CCSprite *tile0 = [layer tileAt:ccp(1,63)];
		CCSprite *tile1 = [layer tileAt:ccp(2,63)];
		CCSprite *tile2 = [layer tileAt:ccp(1,62)];
		CCSprite *tile3 = [layer tileAt:ccp(2,62)];
		tile0.anchorPoint = ccp(0.5f, 0.5f);
		tile1.anchorPoint = ccp(0.5f, 0.5f);
		tile2.anchorPoint = ccp(0.5f, 0.5f);
		tile3.anchorPoint = ccp(0.5f, 0.5f);

		id move = [CCMoveBy actionWithDuration:0.5f position:ccp(0,160)];
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id scale = [CCScaleBy actionWithDuration:2 scale:5];
		id opacity = [CCFadeOut actionWithDuration:2];
		id fadein = [CCFadeIn actionWithDuration:2];
		id scaleback = [CCScaleTo actionWithDuration:1 scale:1];
		id finish = [CCCallFuncN actionWithTarget:self selector:@selector(removeSprite:)];
		id seq0 = [CCSequence actions:move, rotate, scale, opacity, fadein, scaleback, finish, nil];
		id seq1 = [[seq0 copy] autorelease];
		id seq2 = [[seq0 copy] autorelease];
		id seq3 = [[seq0 copy] autorelease];
		
		[tile0 runAction:seq0];
		[tile1 runAction:seq1];
		[tile2 runAction:seq2];
		[tile3 runAction:seq3];
		
		
		gid = [layer tileGIDAt:ccp(0,63)];
		NSLog(@"Tile GID at:(0,63) is: %d", gid);

		[self schedule:@selector(updateCol:) interval:2.0f];
		[self schedule:@selector(repaintWithGID:) interval:2];
		[self schedule:@selector(removeTiles:) interval:1];
		
		
		NSLog(@"++++atlas quantity: %d", [[layer textureAtlas] totalQuads]);
		NSLog(@"++++children: %d", [[layer children] count]);
		
		gid2 = 0;
		
	}	
	return self;
}

-(void) removeSprite:(id) sender
{
	NSLog(@"removing tile: %@", sender);
	id p = [sender parent];
	[p removeChild:sender cleanup:YES];
	NSLog(@"atlas quantity: %d", [[p textureAtlas] totalQuads]);
}

-(void) updateCol:(ccTime)dt
{	
	id map = [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = (CCTMXLayer*) [map getChildByTag:0];
		
	NSLog(@"++++atlas quantity: %d", [[layer textureAtlas] totalQuads]);
	NSLog(@"++++children: %d", [[layer children] count]);


	CGSize s = [layer layerSize];
	for( int y=0; y< s.height; y++ ) {
		[layer setTileGID:gid2 at:ccp(3,y)];
	}
	gid2 = (gid2 + 1) % 80;
}
-(void) repaintWithGID:(ccTime)dt
{
//	[self unschedule:_cmd];
	
	id map = [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = (CCTMXLayer*) [map getChildByTag:0];
	
	CGSize s = [layer layerSize];
	for( int x=0; x<s.width;x++) {
		int y = s.height-1;
		unsigned int tmpgid = [layer tileGIDAt:ccp(x,y)];
		[layer setTileGID:tmpgid+1 at:ccp(x,y)];
	}
}

-(void) removeTiles:(ccTime)dt
{
	[self unschedule:_cmd];

	id map = [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = (CCTMXLayer*) [map getChildByTag:0];
	CGSize s = [layer layerSize];
	for( int y=0; y< s.height; y++ ) {
		[layer removeTileAt:ccp(5,y)];
	}
		
}

-(NSString *) title
{
	return @"TMX Read/Write test";
}
@end

#pragma mark -
#pragma mark TMXTilesetTest

@implementation TMXTilesetTest
-(id) init
{
	if( (self=[super init]) ) {
				
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test5.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		CCTMXLayer *layer;
		layer = [map layerNamed:@"Layer 0"];
		[layer.texture setAntiAliasTexParameters];
		
		layer = [map layerNamed:@"Layer 1"];
		[layer.texture setAntiAliasTexParameters];

		layer = [map layerNamed:@"Layer 2"];
		[layer.texture setAntiAliasTexParameters];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Tileset test";
}
@end

#pragma mark -
#pragma mark TMXOrthoObjectsTest

@implementation TMXOrthoObjectsTest
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/ortho-objects.tmx"];
		[self addChild:map z:-1 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		NSLog(@"----> Iterating over all the group objets");
		CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
		for( NSDictionary *dict in group.objects) {
			NSLog(@"object: %@", dict);
		}
		
		NSLog(@"----> Fetching 1 object by name");
		NSDictionary *platform = [group objectNamed:@"platform"];
		NSLog(@"platform: %@", platform);
	}	
	return self;
}

-(void) draw
{
	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
	for( NSDictionary *dict in group.objects) {
		int x = [[dict objectForKey:@"x"] intValue];
		int y = [[dict objectForKey:@"y"] intValue];
		int width = [[dict objectForKey:@"width"] intValue];
		int height = [[dict objectForKey:@"height"] intValue];
		
		glLineWidth(3);
		
		ccDrawLine( ccp(x,y), ccp(x+width,y) );
		ccDrawLine( ccp(x+width,y), ccp(x+width,y+height) );
		ccDrawLine( ccp(x+width,y+height), ccp(x,y+height) );
		ccDrawLine( ccp(x,y+height), ccp(x,y) );

		
		glLineWidth(1);
	}
}

-(NSString *) title
{
	return @"TMX Ortho object test";
}

-(NSString*) subtitle
{
	return @"You should see a white box around the 3 platforms";
}
@end

#pragma mark -
#pragma mark TMXIsoObjectsTest

@implementation TMXIsoObjectsTest
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-objectgroup.tmx"];
		[self addChild:map z:-1 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
		for( NSDictionary *dict in group.objects) {
			NSLog(@"object: %@", dict);
		}		
	}	
	return self;
}

-(void) draw
{
	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
	for( NSDictionary *dict in group.objects) {
		int x = [[dict objectForKey:@"x"] intValue];
		int y = [[dict objectForKey:@"y"] intValue];
		int width = [[dict objectForKey:@"width"] intValue];
		int height = [[dict objectForKey:@"height"] intValue];
		
		glLineWidth(3);
		
		ccDrawLine( ccp(x,y), ccp(x+width,y) );
		ccDrawLine( ccp(x+width,y), ccp(x+width,y+height) );
		ccDrawLine( ccp(x+width,y+height), ccp(x,y+height) );
		ccDrawLine( ccp(x,y+height), ccp(x,y) );
		
		
		glLineWidth(1);
	}
}

-(NSString *) title
{
	return @"TMX Iso object test";
}

-(NSString*) subtitle
{
	return @"You need to parse them manually. See bug #810";
}
@end
#pragma mark -
#pragma mark TMXTilePropertyTest

@implementation TMXTilePropertyTest
-(id) init
{
	if( (self = [super init]) ){
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/ortho-tile-property.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		for(int i=1;i<=20;i++){
			NSLog(@"GID:%i, Properties:%@", i, [map propertiesForGID:i]);
		}
	}
	return self;
}

-(NSString *) title
{
	return @"TMX Tile Property Test";
}
-(NSString*) subtitle
{
	return @"In the console you should see tile properties";
}
@end

#pragma mark -
#pragma mark TMXResizeTest

@implementation TMXResizeTest
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test5.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		CCTMXLayer *layer;
		layer = [map layerNamed:@"Layer 0"];

		CGSize ls = [layer layerSize];
		for (NSUInteger y = 0; y < ls.height; y++) {
			for (NSUInteger x = 0; x < ls.width; x++) {
				[layer setTileGID:1  at:ccp( x, y )];
			}
		}		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX resize test";
}

-(NSString *) subtitle
{
	return @"Should not crash. Testing issue #740";
}
@end

#pragma mark -
#pragma mark TMXIsoZorder

@implementation TMXIsoZorder
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-zorder.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		[map setPosition:ccp(-700,-50)];
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[map addChild:tamara z: [[map children] count]];
		[tamara retain];
		int mapWidth = map.mapSize.width * map.tileSize.width;
		[tamara setPosition:ccp( mapWidth/2,0)];
		[tamara setAnchorPoint:ccp(0.5f,0)];

		
		id move = [CCMoveBy actionWithDuration:10 position:ccp(300,250)];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(repositionSprite:)];
				
	}	
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	CGPoint p = [tamara position];
	CCNode *map = [self getChildByTag:kTagTileMap];
	
	// there are only 4 layers. (grass and 3 trees layers)
	// if tamara < 48, z=4
	// if tamara < 96, z=3
	// if tamara < 144,z=2
	
	int newZ = 4 - (p.y / 48);
	newZ = MAX(newZ,0);
	
	[map reorderChild:tamara z:newZ];	
}

-(NSString *) title
{
	return @"TMX Iso Zorder";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark -
#pragma mark TMXOrthoZorder

@implementation TMXOrthoZorder
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test-zorder.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[map addChild:tamara z: [[map children] count]];
		[tamara retain];
		[tamara setAnchorPoint:ccp(0.5f,0)];

		
		id move = [CCMoveBy actionWithDuration:10 position:ccp(400,450)];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(repositionSprite:)];
		
	}	
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	CGPoint p = [tamara position];
	CCNode *map = [self getChildByTag:kTagTileMap];
	
	// there are only 4 layers. (grass and 3 trees layers)
	// if tamara < 81, z=4
	// if tamara < 162, z=3
	// if tamara < 243,z=2

	// -10: customization for this particular sample
	int newZ = 4 - ( (p.y-10) / 81);
	newZ = MAX(newZ,0);

	[map reorderChild:tamara z:newZ];
}

-(NSString *) title
{
	return @"TMX Ortho Zorder";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark -
#pragma mark TMXIsoVertexZ

@implementation TMXIsoVertexZ
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-vertexz.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		[map setPosition:ccp(-700,-50)];
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// because I'm lazy, I'm reusing a tile as an sprite, but since this method uses vertexZ, you
		// can use any CCSprite and it will work OK.
		CCTMXLayer *layer = [map layerNamed:@"Trees"];
		tamara = [layer tileAt:ccp(29,29)];
		[tamara retain];
		
		id move = [CCMoveBy actionWithDuration:10 position:ccp(300,250)];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(repositionSprite:)];
		
	}	
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	// tile height is 64x32
	// map size: 30x30
	CGPoint p = [tamara position];
	[tamara setVertexZ: -( (p.y+32) /16) ];
}

-(void) onEnter
{
	[super onEnter];
	
	// TIP: 2d projection should be used
	[self.director setProjection:kCCDirectorProjection2D];
}

-(void) onExit
{
	// At exit use any other projection. 
	//	[self.director setProjection:kCCDirectorProjection3D];
	[super onExit];
}

-(NSString *) title
{
	return @"TMX Iso VertexZ";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark -
#pragma mark TMXOrthoVertexZ

@implementation TMXOrthoVertexZ
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test-vertexz.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// because I'm lazy, I'm reusing a tile as an sprite, but since this method uses vertexZ, you
		// can use any CCSprite and it will work OK.
		CCTMXLayer *layer = [map layerNamed:@"trees"];
		tamara = [layer tileAt:ccp(0,11)];
		[tamara retain];

		id move = [CCMoveBy actionWithDuration:10 position:ccp(400,450)];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(repositionSprite:)];
		
	}	
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	// tile height is 101x81
	// map size: 12x12
	CGPoint p = [tamara position];
	[tamara setVertexZ: -( (p.y+81) /81) ];
}

-(void) onEnter
{
	[super onEnter];
	
	// TIP: 2d projection should be used
	[self.director setProjection:kCCDirectorProjection2D];
}

-(void) onExit
{
	// At exit use any other projection. 
	//	[self.director setProjection:kCCDirectorProjection3D];
	[super onExit];
}

-(NSString *) title
{
	return @"TMX Ortho vertexZ";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark -
#pragma mark TMXIsoMoveLayer

@implementation TMXIsoMoveLayer
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-movelayer.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		[map setPosition:ccp(-700,-50)];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Iso Move Layer";
}

-(NSString *) subtitle
{
	return @"Trees should be horizontally aligned";
}
@end

#pragma mark -
#pragma mark TMXOrthoMoveLayer

@implementation TMXOrthoMoveLayer
-(id) init
{
	if( (self=[super init]) ) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test-movelayer.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Ortho Move Layer";
}

-(NSString *) subtitle
{
	return @"Trees should be horizontally aligned";
}
@end

// CLASS IMPLEMENTATIONS

#pragma mark -
#pragma mark AppController - iPhone

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	
	// get instance of the shared director
	CCDirector *director_ = director;
	
	// before creating any layer, set the landscape mode
	[self.director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[self.director setDisplayFPS:YES];
	
	// frames per second
	[self.director setAnimationInterval:1.0/60];
	
	// create an OpenGL view a depth buffer of 16-bits (needed for z ordering)
	//   and an RGB8 color buffer
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT16_OES
							preserveBackbuffer:NO];
	[glView setMultipleTouchEnabled:YES];
	
	// connect it to the director
	[self.director setOpenGLView:glView];
	
	// glview is a child of the main window
	[window addSubview:glView];
	
	// Make the window visible
	[window makeKeyAndVisible];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	//
	// Run all the test with 2d projection
	//
	[self.director setProjection:kCCDirectorProjection2D];

	
	//
	// Finally, run the scene
	//
	[self.director runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[self.director pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[self.director resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[self.director stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[self.director startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director_ = director;
	[[self.director openGLView] removeFromSuperview];
	[self.director end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[self.director purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[self.director setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	
	CCDirector *director_ = director;
	
	[self.director setDisplayFPS:YES];
	
	[self.director setOpenGLView:glView_];
	
	//	[self.director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	//
	// Run all the test with 2d projection
	//
	[self.director setProjection:kCCDirectorProjection2D];
	
	
	//
	// Finally, run the scene
	//
	[self.director runWithScene: scene];
}

@end
#endif

