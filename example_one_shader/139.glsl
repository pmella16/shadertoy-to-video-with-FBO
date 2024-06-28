const vec3 scales = vec3(
   4.,4.,8.
   //2.,2.,8.
   //4.,2.,8.
   //2.,2.,4.
);

#define triwave(p) abs(fract(.5+p/scales[0])-.5)*2.
#define triwave1(p) (abs(fract(p/scales[1])-.5)-abs(fract(p/scales[2])-.5)/2.)

vec4 t1(vec2 c, vec2 p){
    return triwave((.5 - length( min(p=fract(p*sign(triwave1(c*c.y))), 1.-p.yx) )) * vec4(22,7,5,0));
}

void mainImage(out vec4 O, vec2 I)
{
    float t = iTime/2.;
    vec2 p = (I/1e2+t);
    vec4 t_ = t1(ceil(p),p);
    vec4 t1_ = vec4(0.),
    t3_ = vec4(0.);
    float scale = 2.;
    
    for(int i = 0; i < 3;i++){
        
        t1_ = t1(ceil(p/scale),p/scale);
        
        //crazy psychedelic animation
        //t1_ += triwave(iTime/8.+t3_);

        scale *= 2.;
        t3_ =
            //1.-min(t_,t1_);
            //1.-min(t_.yzxw,t1_)
        
            //crazy psychedelic animation
            //1.-min(t_,t1(ceil(p/(scale)+t1_.y-t),p/(scale)+t1_.y-t));
            1.-min(t_.yzxw,t1(ceil(p/(scale)+t1_.y-iTime),p/(scale)+t1_.y-iTime))

        ;
        

        if(
            //Lots of interesting patterns here!
            t3_.x>t1_.x
            //t3_.y-triwave1(iTime-p.x)>t1_.y-triwave1(iTime-p.y)
            //t_.y>t_.x
            //t1_.y>t1_.z
            //1.-t_.z>t1_.y||1.-t_.y>t1_.x||1.-t_.x>t1_.z

            //t1_.y>t_.y||t1_.z>t_.z||t1_.x>t_.x
            //t_.y<t1_.y

            //t_.x>t1_.x&&t_.y<t1_.x
            //t_.z>.5||t_.y>.5||t_.z>.5
            //t1_.z>t_.z||t1_.y>t_.y||t1_.z>t_.z
        ) t_ =
            1.-t1_
            //t1_.yzxw
        ;
    }
    O = t3_;
}