#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)cos((h)*6.3+vec3(0,23,21))*.5+.5


mat2 myinverse(mat2 m) {
    float determinant = m[0][0] * m[1][1] - m[0][1] * m[1][0];
    return mat2(m[1][1], -m[0][1],
                -m[1][0], m[0][0]) / determinant;
}


const float PLASTIC = 1.324717957244746;
const float PLASTIC_2 = pow( PLASTIC, 2. );
const float PLASTIC_3 = pow( PLASTIC, 3. );
const float PLASTIC_4 = pow( PLASTIC, 4. );
const float PLASTIC_5 = pow( PLASTIC, 5. );
const float PLASTIC_6 = pow( PLASTIC, 6. );
const float PLASTIC_7 = pow( PLASTIC, 7. );
const float PLASTIC_8 = pow( PLASTIC, 8. );
const float PLASTIC_9 = pow( PLASTIC, 9. );
mat2 TO_HEX0_HEX1;



const vec2 HEX0 = vec2( 1., 0. );
const vec2 HEX1 = vec2( .5, sqrt( .75 ) );

// Declaración de la variable TO_HEX0_HEX1 como no constante





const vec2 RECURSE_PT = vec2( PLASTIC_7 - PLASTIC_3, PLASTIC_3 );

const vec2 FIXED_PT = mix( RECURSE_PT, vec2( 0. ), -1./(PLASTIC_8-1.) );

// shape of the tile
bool inTile( vec2 h ) // h is in hex coords
{
    if ( h.y < 0. ) return false;  
    if ( h.x < 0. ) return false;
    if ( h.x + h.y > PLASTIC_9 ) return false;  
    if ( h.x + h.y > PLASTIC_8 && h.x < PLASTIC_6 ) return false;
    return true;
}

// map subtile -> parent tile
vec2 fromBigTile( vec2 h )
{
    return h.yx * PLASTIC;
}
// map subtile -> parent tile
vec2 fromMediumTile( vec2 h )
{
    return mat2( 0., -1., 1., -1. ) * (h - vec2(PLASTIC_9, 0.)) * PLASTIC_2;
}
// map subtile -> parent tile
vec2 fromSmallTile( vec2 h )
{
    return mat2( -1., 1., 0., 1. ) * (h - vec2(PLASTIC_7, 0.)) * PLASTIC_4;
}

const int NO_TILE = -1;
const int SMALL_TILE = 0;
const int MEDIUM_TILE = 1;
const int BIG_TILE = 2;
vec2 substitution( vec2 h, out int tileType )
{
    vec2 hh;
    hh = fromBigTile( h );    if ( inTile( hh ) ) { tileType = BIG_TILE;    return hh; }
    hh = fromMediumTile( h ); if ( inTile( hh ) ) { tileType = MEDIUM_TILE; return hh; }
    hh = fromSmallTile( h );  if ( inTile( hh ) ) { tileType = SMALL_TILE;  return hh; }
    tileType = NO_TILE;  
    return h;
}

vec3 colorForTile( int tileType )
{
    if ( tileType == BIG_TILE ) return vec3( 1., 0., 0. );
    if ( tileType == MEDIUM_TILE ) return vec3( 0., 1., 0. );
    if ( tileType == SMALL_TILE ) return vec3( 0., 0., 1. );
    return vec3( 0., 0., 0. );
}

// tile size
float zoom( int tileType )
{
    if ( tileType == BIG_TILE ) return 1.;
    if ( tileType == MEDIUM_TILE ) return 2.;
    if ( tileType == SMALL_TILE ) return 4.;
    return 999.;
}

//
float bump( float x )
{
    return smoothstep( -2., 5., abs( x ) ) - smoothstep( 5., 32., abs( x ) );
}

vec3 go( vec2 h, float viewportZoom )
{      
    vec3 color = vec3( 0. );
    int tileType;    
   
    float totalZoom = viewportZoom;

    float colorScale = 1.;
    while ( totalZoom < 50. )
    {    
        h = substitution( h, tileType );
        color += colorForTile( tileType ) * bump( totalZoom ) * .15 * mix( 2., 0.2, totalZoom/20. );
        totalZoom += zoom( tileType );
    }
       
    return color;
}
void mainImage(out vec4 O, vec2 C)
{

      TO_HEX0_HEX1 = myinverse(mat2(HEX0, HEX1));
      
    O=vec4(0);
   
    vec2 uv = (C*2.-iResolution.xy)/iResolution.y;
   

    vec2 h = TO_HEX0_HEX1 * uv;
   

    float t = iTime;
    float viewportZoom = mod( t * 0.1, 4. ) * -2. - 16.;
   
    h *= pow( PLASTIC, viewportZoom );
    h += FIXED_PT;    
   
    vec3 col = go( h, viewportZoom );    
   
   
    vec3 p,r=iResolution,
    d=normalize(vec3((C-.5*r.xy)/r.y,1));  
   
    for(
        float i=0.,g=0.,e,s;
        ++i<99.;
        O.rgb+=mix(r/r,H(log(s)),.7)*.05*exp(-.45*i*i*e))
    {
        p=g*d-vec3(0,.0,-4.5+h);
     
        p=R(p,normalize(vec3(0,0,1)),h.y+iTime);
        s=4.;
        vec4 q=vec4(p,sin(iTime*.4)*.5);
for(int j=0;j++<8;)
            q=abs(q),
            q=q.x<q.y?q.zwxy:q.zwyx ,
                  q=q.w<q.z?q.xyzw:q.xyzw ,
            s*=e=1.35/min(dot(q,q),0.54),
            q=q*e-vec4(0,4,.8,3);
        g+=e=min(
            length(q.w)/s,
            length(cross(q.xyz,normalize(vec3(1,2,3))))/s-.0002
        );
    }
    O=pow(O,vec4(5));
 }

