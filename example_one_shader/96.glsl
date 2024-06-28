#define iterations 19 // Кількість ітерацій для формули
#define formuparam 0.65 // Параметр формули

#define volsteps 25 // Кількість кроків для волюметричного рендерингу
#define stepsize 0.15 // Величина кроку

#define zoom   0.999 // Зум
#define tile   0.999 // Розмір плитки
#define speed  0.003 // Швидкість

#define brightness 0.0002 // Яскравість
#define darkmatter 0.300 // Контраст переднього фону
#define distfading 0.750 // Згасання відстані
#define saturation 0.999 // Насиченість

// Нові параметри для кольору
#define color1 vec3(0.0, 0.1, 0.2)  // Початковий колір
#define color2 vec3(0.2, 0.0, 0.1)  // Кінцевий колір
#define colorTransitionDistance 30.0 // Відстань, на якій відбувається перехід між кольорами

// Функція для створення S-кривої
float SCurve(float value) {
    if (value < 0.5) {
        return value * value * value * value * value * 15.0; 
    }
    value -= 1.0;
    return value * value * value * value * value * 15.0 + 1.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Отримання координат та напрямку
    vec2 uv = fragCoord.yx / iResolution.xy - 0.5;
    uv.y *= iResolution.y / iResolution.x;
    vec3 directionCameraMove = vec3(-uv * zoom, 1.0); 
    float time = iTime * speed + 0.25;
    
    vec3 startPoint = vec3(1.0, 0.5, 0.5) + vec3(time * -1.0, time, 1.0);
    
    // Волюметричний рендеринг
    float stepSize = 0.15, fade = 0.75;
    vec3 colorAccumulator = vec3(-1.0);
    for (int step = 0; step < volsteps; step++) {
        vec3 position = startPoint + stepSize * directionCameraMove * 0.999;
        position = abs(vec3(tile) - mod(position, vec3(tile * 2.5))); // згортання
        float prevLength, currentLength = prevLength = 0.0;
        for (int i = 0; i < iterations; i++) { 
            position = abs(position) / dot(position, position) - formuparam; 
            currentLength += abs(length(position) - prevLength); 
            prevLength = length(position);
        }
        float darkMatter = max(0.0, darkmatter - currentLength * currentLength * 0.001); // розмір темних матерій
        currentLength *= currentLength * currentLength; // додавання контрасту
        if (step > 3) fade *= 1.0 - darkMatter; // віддалення темної матерії подалі від камери
        
        colorAccumulator += vec3(darkMatter, darkMatter * 0.6, 0.0);
        colorAccumulator += fade;
        colorAccumulator += vec3(
        stepSize, stepSize * stepSize, stepSize * stepSize * stepSize * stepSize) 
        * currentLength * brightness * fade; // колірування залежно від відстані
        
        fade *= distfading; // згасання залежно від відстані
        stepSize += stepsize;
    }
    
    colorAccumulator = mix(vec3(length(colorAccumulator)), colorAccumulator, saturation); // колірна корекція
    
    vec4 pixelColor = vec4(colorAccumulator * 0.01, 1.0);
    
    // Гамма-корекція
    pixelColor.r = pow(pixelColor.r, 0.35); 
    pixelColor.g = pow(pixelColor.g, 0.36); 
    pixelColor.b = pow(pixelColor.b, 0.4); 
    
    vec4 finalColor = pixelColor;   	
    
    // Застосування S-кривої для кожного кольору
    finalColor.r = mix(finalColor.r, SCurve(finalColor.r), 1.0); 
    finalColor.g = mix(finalColor.g, SCurve(finalColor.g), 0.9); 
    finalColor.b = mix(finalColor.b, SCurve(finalColor.b), 0.6);     	
    
    fragColor = finalColor;	
}
