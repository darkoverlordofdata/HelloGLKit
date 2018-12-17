/*******************************************************************
** This code is part of the Dark Framework.
**
MIT License

Copyright (c) 2018 Dark Overlord of Data

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************/
#import <GLKit/GLKit.h>

typedef struct Vertex  {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    // Front
    {{1, -1, 1},	{1, 0, 0, 1},	{1, 0}},
    {{1, 1, 1},		{0, 1, 0, 1},	{1, 1}},
    {{-1, 1, 1},	{0, 0, 1, 1},	{0, 1}},
    {{-1, -1, 1},	{0, 0, 0, 1},	{0, 0}},
    // Back
    {{1, 1, -1},	{1, 0, 0, 1},	{0, 1}},
    {{-1, -1, -1},	{0, 1, 0, 1},	{1, 0}},
    {{1, -1, -1},	{0, 0, 1, 1},	{0, 0}},
    {{-1, 1, -1},	{0, 0, 0, 1},	{1, 1}},
    // Left
    {{-1, -1, 1},	{1, 0, 0, 1},	{1, 0}}, 
    {{-1, 1, 1},	{0, 1, 0, 1},	{1, 1}},
    {{-1, 1, -1},	{0, 0, 1, 1},	{0, 1}},
    {{-1, -1, -1},	{0, 0, 0, 1},	{0, 0}},
    // Right
    {{1, -1, -1},	{1, 0, 0, 1},	{1, 0}},
    {{1, 1, -1},	{0, 1, 0, 1},	{1, 1}},
    {{1, 1, 1},		{0, 0, 1, 1},	{0, 1}},
    {{1, -1, 1},	{0, 0, 0, 1},	{0, 0}},
    // Top
    {{1, 1, 1},		{1, 0, 0, 1},	{1, 0}},
    {{1, 1, -1},	{0, 1, 0, 1},	{1, 1}},
    {{-1, 1, -1},	{0, 0, 1, 1},	{0, 1}},
    {{-1, 1, 1},	{0, 0, 0, 1},	{0, 0}},
    // Bottom
    {{1, -1, -1},	{1, 0, 0, 1},	{1, 0}},
    {{1, -1, 1},	{0, 1, 0, 1},	{1, 1}},
    {{-1, -1, 1},	{0, 0, 1, 1},	{0, 1}}, 
    {{-1, -1, -1},	{0, 0, 0, 1},	{0, 0}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

/**
 * This is the main GameView
 */
@interface GameViewController : GLKViewController;

@property (nonatomic) float curRed; 
@property (nonatomic) BOOL increasing;
@property (nonatomic) GLuint vertexBuffer;
@property (nonatomic) GLuint indexBuffer;
@property (nonatomic) GLuint vertexArray;
@property (nonatomic) float rotation;
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end


@implementation GameViewController;
- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_CULL_FACE);
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft, 
                              nil];

    NSError *error;    
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"tile_floor" ofType : @"png"];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (info == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
    self.effect.texture2d0.name = info.name;
    self.effect.texture2d0.enabled = true;

    // New lines
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    // Old stuff
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    // New lines (were previously in draw)
    glEnableVertexAttribArray(GLKVertexAttribPosition);        
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));
    
    // New line
    glBindVertexArrayOES(0);
	glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [self setupGL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    [self.effect prepareToDraw];    
    
    glBindVertexArrayOES(_vertexArray);   
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
}


- (void)update {
    if (_increasing) {
        _curRed += 1.0 * self.timeSinceLastUpdate;
    } else {
        _curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	//NSLog(@"%f,%f", self.view.bounds.size.width, self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);   
    _rotation += 90 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(25), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 1, 0);    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent : (UIEvent *)event {
	NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
	NSLog(@"timeSinceLastDraw: %f", self.timeSinceLastDraw);
	//NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
	//NSLog(@"timeSinceLastResume: %f", self.timeSinceLastResume);
	self.paused = !self.paused;

	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView : self.view];

	NSLog(@"%f,%f", point.x, point.y);

}

@end
