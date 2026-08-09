// 
import flixel.effects.particles.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitterMode;

import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LabelValuePair;

import flixel.math.FlxVelocity;
import flixel.util.FlxStringUtil;
import flixel.util.IFlxDestroyable;

var maxTimeTween:FlxTween;
public var snow:CustomShader;
public var heat:CustomShader = null;
public var heat2:CustomShader = null;

public var waterParticle:FlxSprite;
public var backEmitter:ParticleEmitter;
public var frontEmitter:ParticleEmitter;

function create() {
    heat2 = new CustomShader("waterDistortion");
    heat = new CustomShader("waterDistortion");
    if (Options.gameplayShaders && FlxG.save.data.water) {
        FlxG.camera.addShader(heat2);
        camHUD.addShader(heat2);
    }
    heat.strength = 0;
    heat2.strength = 0;

    
    snow = importScript("data/scripts/cornered-shader");
    snow.set("initIndex", members.length);
    snow.set("isOn", false);

    waterParticle = new FlxSprite().loadGraphic(Paths.image("particle_cornered"));
    waterParticle.blend = 0;
    waterParticle.antialiasing = Options.antialiasing;

    backEmitter = new ParticleEmitter(waterParticle);
    backEmitter.scrollFactor.set(0.8, 0.8);
    backEmitter.scale = 2;

    backEmitter.addSpawnPoint(-600, 325, 300);
    backEmitter.addSpawnPoint(-600, 680, 300);
    backEmitter.addSpawnPoint(90, 700, 350);
    backEmitter.addSpawnPoint(1100, 550, 250);
    backEmitter.addSpawnPoint(1200, 660, 400);
    backEmitter.addSpawnPoint(760, 440, 250);

    insert(members.indexOf(stage.stageSprites["wall_left"]), backEmitter);


    //FRONT PARTICLES

    frontEmitter = new ParticleEmitter(waterParticle);
    frontEmitter.scrollFactor.set(1.05, 1.05);
    frontEmitter.scale = 2.5;
    frontEmitter.alpha = 0.8;
    frontEmitter.duration = 2;
    frontEmitter.maxLimit = 15;

    frontEmitter.addSpawnPoint(-500, 1200, 2500);

    add(frontEmitter);
    /*
    spawnWaterEmitter(-600, 325, 300);
    spawnWaterEmitter(-600, 680, 300);
    spawnWaterEmitter(90, 700, 350);
    spawnWaterEmitter(1100, 550, 250);
    spawnWaterEmitter(1200, 660, 400);
    spawnWaterEmitter(760, 440, 250);
    */
}

var tottalTimer:Float = FlxG.random.float(50, 300);

function update(elapsed:Float) {
    //trace(FlxG.camera.followLerp * 1000);
    heat?.time = (tottalTimer += elapsed);
    heat2?.time = (tottalTimer += elapsed);
    bg_front.animation.pause();
}

// LUNAR PLS FIX THESE THEYRE MAKING THE RAM GO CRAZY:SOB:  - Nex
// don't worry I fixed it >:) - hig ig
/*function spawnWaterEmitter(ex:Float, ey:Float, ewidth:Float) {
    
    emitter = new FlxTypedEmitter(ex, ey);
    
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(-30, -300, 30, 0);
    emitter.alpha.set(.2, .4, 0, 0);
    emitter.lifespan.set(1, 2);

    emitter.width = ewidth;
    emitter.maxSize = 40;

    for (i in 0...emitter.maxSize) {
        var particle:FlxParticle = new FlxParticle();
        var size:Int = [3, 4, 8][FlxG.random.int(0,2)];
        particle.makeGraphic(size, size, 0x00FFFFFF);
        particle.scrollFactor.set(0.8, 0.8);
        FlxSpriteUtil.drawCircle(particle, size/2, size/2, size/2, CoolUtil.lerpColor(0xFFB2DFE9, 0xFF408696, FlxG.random.float(0, 1)));
        emitter.add(particle);
    }

    insert(members.indexOf(stage.stageSprites["wall_left"]), emitter);
    //add(emitter);
    emitter.start(false, 0.08);
}*/

class ParticleEmitter extends FlxBasic {


    private var _spawnTimer:Float = 0;

    var _pool:Array<Dynamic> = [];

    public var scale:Float = 1;
    public var alpha:Float = 1;
    public var scrollFactor:FlxPoint = FlxPoint.get(1,1);

    public var dummy:FlxSprite;

    public var spawnPoints:Array<ParticleSpawnPoint> = [];
    public var particles:Array<ParticleData> = [];
    public var maxLimit:Float = 40;

    public var duration:Float = 0.5;
    public var speed:Float = 1;

    public function new(_dummy:FlxSprite) {
        super();
        if(_dummy != null)
            dummy = _dummy;
    }

    public function addSpawnPoint(_x:Float, _y:Float, _width:Float) {
        var spawnPoint = {
            x: _x,
            y: _y,
            width: _width,
            limit: maxLimit,
            timer: 0,
            particles: [],
            _spawnEndTime: FlxG.random.float(0.8, 1.5),
            toString: null
        }

        spawnPoint.toString = () -> {
            return FlxStringUtil.getDebugString([
                LabelValuePair.weak("x", spawnPoint.x),
                LabelValuePair.weak("y", spawnPoint.y),
                LabelValuePair.weak("width", spawnPoint.width),
                LabelValuePair.weak("timer", spawnPoint.timer),
                LabelValuePair.weak("particles", spawnPoint.particles)
            ]);
        }

        spawnPoints.push(spawnPoint);
	}

    public var colors:Array<Int> = [0xFFA5ECFC, 0xFF408696];

    public override function update(elapsed:Float) {
        super.update(elapsed);

        for(i => spawnPoint in spawnPoints) {
            if(spawnPoint.timer > spawnPoint._spawnEndTime && spawnPoint.particles.length < maxLimit) {
                var particle:Dynamic;
                if(_pool[0] != null) {
                    particle = _pool[0];
                    particle.x = spawnPoint.x + FlxG.random.float(0, spawnPoint.width);
                    particle.y = spawnPoint.y;
                    particle.alpha = 0;
                    particle.timer = 0;
                    _pool.remove(_pool[0]);
                } else {
                    particle = {
                        color: CoolUtil.lerpColor(colors[0], colors[1], FlxG.random.float(0, 1)),
                        x: spawnPoint.x + FlxG.random.float(0, spawnPoint.width),
                        y: spawnPoint.y,
                        size: [3, 4, 8][FlxG.random.int(0,2)],
                        velocity: FlxG.random.float(-150, -250),
                        alpha: 0,
                        timer: 0,

                        _endLimit: FlxG.random.float(duration * .25, duration),
                    }
                }

                FlxTween.num(0, 1, 0.4 / speed, {}, (num) -> {
                    if(particle != null)
                        particle.alpha = num;
                });

                particles.push(particle);
                spawnPoint.particles.push(particle);
                spawnPoint._spawnEndTime = FlxG.random.float(0.25, 0.4);
                spawnPoint.timer = 0;
            } else spawnPoint.timer += elapsed * speed;

            for(particle in spawnPoint.particles) {
                var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(particle.velocity, 0, 0, 0, elapsed * speed) - particle.velocity);
                particle.velocity += velocityDelta;
                var delta = (particle.velocity) * (elapsed * speed);
                particle.velocity += velocityDelta;
                particle.y += delta;

                if(particle.timer > particle._endLimit && particle.alpha == 1) {
                    FlxTween.cancelTweensOf(particle);
                    FlxTween.num(particle.alpha, 0, 1 / speed,
                    {
                        onComplete: (_) -> {
                            particles.remove(particle);
                            spawnPoint.particles.remove(particle);
                            _pool.push(particle);
                        }
                    }, (num) -> {
                        if(particle != null)
                            particle.alpha = num;
                    });
                } else particle.timer += elapsed;
            }
        }
    }

    public override function draw() {
        for(particle in particles) {
            dummy.setGraphicSize(particle.size * scale, particle.size * scale);
            dummy.updateHitbox();
            dummy.setPosition(particle.x, particle.y);
            dummy.scrollFactor = scrollFactor;
            dummy.alpha = particle.alpha * alpha;
            dummy.color = particle.color;
            dummy.draw();
        }
        dummy.scale.set(0, 0);
        dummy.alpha = 0;
    }

    public override function destroy() {
        super.destroy();

        alpha = null;
        velocity = null;
    }
}