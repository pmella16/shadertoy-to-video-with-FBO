#define triwave(p) abs(fract(.5+p/4.0)-.5)*2.
#define triwave1(p) (abs(fract(p/8.0)-.5)-abs(fract(p/2.0)-.5)/2.)

vec4 t1(vec2 c, vec2 p){
    return triwave((.5 - length( min(p=fract(p*sign(triwave1(c*c.y))), 1.-p.yx) )) * vec4(22,7,5,0));
}

void mainImage(out vec4 O, vec2 I)
{
    vec2 p = (I/1e2);
    vec4 t_ = t1(ceil(p),p);
    vec4 t1_ = vec4(0.),t2_ = vec4(0.),
    t3_ = vec4(0.);
    float scale = 2.;
    
    for(int i = 0; i < 3;i++){
        t1_ = t1(ceil(p/scale/16.+iTime/16.),p/scale/16.+iTime/32.);
        t2_ = t1(ceil(p/(scale)-t1_.x),p/(scale)-t1_.y);
        scale *= 2.;
        
        //scale *= 2.;
        t3_ = 1.-min(t_,t2_);
        if(
            //Lots of interesting patterns here!
            t3_.y>t1_.y
            //t_.y>t_.x
            //t1_.y>t1_.z
            //1.-t_.z>t1_.y||1.-t_.y>t1_.x||1.-t_.x>t1_.z

            //t1_.y>t_.y||t1_.z>t_.z||t1_.x>t_.x
            //t_.y<t1_.y

            //t_.x>t1_.x&&t_.y<t1_.x
            //t_.z>.5||t_.y>.5||t_.z>.5
            //t1_.z>t_.z||t1_.y>t_.y||t1_.z>t_.z
        ) t_ = 1.-t2_;
    }
    O = t3_;
}