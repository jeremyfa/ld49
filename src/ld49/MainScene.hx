package ld49;

import ceramic.Color;
import ceramic.Point;
import ceramic.Quad;
import ceramic.Scene;
import ceramic.StateMachine;
import ceramic.Text;
import ceramic.Timer;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;

using ceramic.Extensions;
using ceramic.VisualTransition;

enum GameState {

    TITLE;

    PLAY;

    GAME_OVER;

}

class MainScene extends Scene {

    @component var machine = new StateMachine<GameState>();

    static var _point = new Point();

    var background:Background;

    var platform:PlatformShape;

    var pillar:PillarShape;

    var allShapes:Array<TeethShape> = [];

    var mainShape:TeethShape = null;

    var xSpeed:Float = 200;

    var ySpeed:Float = 400;

    var teethCollisionType = new CbType();

    var shapeConfigs:Array<Array<Int>> = [
        [1, 0, 0xFEC260],
        [1, 1, 0xFEC260],
        [2, 0, 0xFEC260],
        [2, 1, 0xFEC260],
        [4, 0, 0xFEC260],
        [4, 1, 0xFEC260],
        [4, 2, 0xFCB636],
        [3, 2, 0xFCB636],
        [3, 3, 0xFCB636],
        [4, 3, 0xFCB636]
    ];

    var colors:Array<Color> = [
        Color.LIME,
        Color.YELLOW,
        Color.RED,
        Color.PINK
    ];

    var scoreTitleText:Text;

    var scoreValueText:Text;

    var mainTitleText:Text;

    var mainTitleTextShadow:Text;

    var descText:Text;

    var score:Int = 0;

    var floating:Floating = null;

    var musicPlaying = false;

    var copyrightText:Text;

    override function preload() {

        assets.add(Fonts.ROBOTO_BOLD);
        assets.add(Sounds.ITWILLFALL_MUSIC);

    }

    override function create() {

        clip = this;

        var listener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, teethCollisionType, teethCollisionType, teethCollision);
        app.nape.space.listeners.add(listener);

        background = new Background();
        background.size(width, height);
        background.pos(width * 0.5, height * 0.5);
        background.anchor(0.5, 0.5);
        background.createShapes();
        background.depth = 1;
        add(background);

        copyrightText = new Text();
        copyrightText.pointSize = 10;
        copyrightText.anchor(0.5, 1);
        copyrightText.depth = 20;
        copyrightText.align = CENTER;
        copyrightText.content = "JAM GAME CREATED IN 48 HOURS 24 HOURS BY JÉRÉMY FAIVRE\ndidn't have much time this WE :')";
        copyrightText.pos(width * 0.5, height - 15);
        add(copyrightText);

        var strike = new Quad();
        strike.size(50, 1);
        strike.anchor(0, 0.5);
        strike.pos(110, 5);
        copyrightText.add(strike);

        machine.state = TITLE;

    }

    override function update(delta:Float) {

        background.update(delta);

    }

    function TITLE_enter() {

        trace('press SPACE to start');

        if (mainTitleText != null)
            mainTitleText.destroy();

        if (mainTitleTextShadow != null)
            mainTitleTextShadow.destroy();

        mainTitleText = new Text();
        mainTitleText.align = CENTER;
        mainTitleText.anchor(0.5, 0.5);
        mainTitleText.pointSize = 80;
        mainTitleText.active = false;
        mainTitleText.depth = 20;
        mainTitleText.font = assets.font(Fonts.ROBOTO_BOLD);
        add(mainTitleText);

        mainTitleTextShadow = new Text();
        mainTitleTextShadow.align = CENTER;
        mainTitleTextShadow.anchor(0.5, 0.5);
        mainTitleTextShadow.pointSize = 80;
        mainTitleTextShadow.active = false;
        mainTitleTextShadow.depth = 19.9;
        mainTitleTextShadow.font = assets.font(Fonts.ROBOTO_BOLD);
        mainTitleTextShadow.color = Color.BLACK;
        mainTitleTextShadow.alpha = 0.5;
        add(mainTitleTextShadow);

        mainTitleText.active = true;
        mainTitleText.pos(width * 0.5, height * 0.4);
        mainTitleText.content = 'IT WILL FALL';

        mainTitleTextShadow.active = true;
        mainTitleTextShadow.pos(width * 0.5, height * 0.4 + 8);
        mainTitleTextShadow.content = 'IT WILL FALL';

        mainTitleText.component(new Floating());
        mainTitleTextShadow.component(new Floating());

        descText = new Text();
        descText.align = CENTER;
        descText.anchor(0.5, 0.5);
        descText.pointSize = 20;
        descText.depth = 20;
        add(descText);

        descText.pos(width * 0.5, height * 0.7);
        descText.content = 'PRESS SPACE TO START GAME';
        Timer.interval(descText, 0.5, function() {
            descText.visible = !descText.visible;
        });
        add(descText);

    }

    function TITLE_update(delta:Float) {

        if (input.keyJustPressed(SPACE)) {
            machine.state = PLAY;

            if (!musicPlaying) {
                musicPlaying = true;
                #if web
                app.backend.audio.resumeAudioContext(_ -> {
                #end
                assets.sound(Sounds.ITWILLFALL_MUSIC).play(0, true);
                #if web
                });
                #end
            }
        }

    }

    function TITLE_exit() {

        if (mainTitleText != null)
            mainTitleText.destroy();

        if (mainTitleTextShadow != null)
            mainTitleTextShadow.destroy();

        if (descText != null)
            descText.destroy();

    }

    function cleanPreviousGame() {

        if (pillar != null) {
            pillar.destroy();
            pillar = null;
        }

        if (platform != null) {
            platform.destroy();
            platform = null;
        }

        while (allShapes.length > 0) {
            allShapes.pop().destroy();
        }

        mainShape = null;

    }

    function PLAY_enter() {

        log.info('PLAY!');

        cleanPreviousGame();

        score = 0;
        addScore(0);

        copyrightText.active = false;

        pillar = new PillarShape();
        pillar.pos(width * 0.5, height * 0.9);
        pillar.depth = 10;
        add(pillar);

        platform = new PlatformShape();
        platform.depthRange = -1;
        platform.pos(
            width * 0.5,
            pillar.y - platform.height * 0.49
        );
        platform.depth = 10;
        add(platform);

        app.nape.space.gravity.y = 200;

        platform.initNapePhysics(DYNAMIC);
        pillar.initNapePhysics(STATIC);

        platform.nape.body.cbTypes.add(teethCollisionType);
        //pillar.nape.body.cbTypes.add(teethCollisionType);

        if (scoreTitleText == null) {
            scoreTitleText = new Text();
            scoreTitleText.color = Color.WHITE;
            scoreTitleText.pointSize = 20;
            scoreTitleText.content = 'SCORE';
            scoreTitleText.anchor(0.5, 1);
            scoreTitleText.depth = 20;
        }
        if (scoreValueText == null) {
            scoreValueText = new Text();
            scoreValueText.color = Color.WHITE;
            scoreValueText.pointSize = 32;
            scoreValueText.content = '' + score;
            scoreValueText.anchor(0.5, 0);
            scoreValueText.depth = 20;
        }

        platform.add(scoreTitleText);
        platform.add(scoreValueText);

        scoreTitleText.scale(1);
        scoreValueText.scale(1);

        scoreTitleText.pos(60, 40);
        scoreValueText.pos(60, 40 + 10);

        addShape();

    }

    function PLAY_exit() {

        copyrightText.active = true;

    }

    function teethCollision(collision:InteractionCallback) {

        if (machine.state != PLAY)
            return;

        if (mainShape != null) {
            var didCollide = false;
            var didCollidWithPlatform = false;
            if (collision.int1.castBody == mainShape.nape.body) {
                if (collision.int2.castBody == platform.nape.body) {
                    didCollidWithPlatform = true;
                }
                didCollide = true;
            }
            else if (collision.int2.castBody == mainShape.nape.body) {
                if (collision.int1.castBody == platform.nape.body) {
                    didCollidWithPlatform = true;
                }
                didCollide = true;
            }

            if (didCollide) {

                updatePointFromPlatform();

                if (Math.abs(mainShape.x - _point.x) < 16 && Math.abs(mainShape.y - _point.y) < 16 && !didCollidWithPlatform) {
                    mainShape = null;
                    machine.state = GAME_OVER;
                }
                else {
                    addScore(mainShape.steps + Math.round(mainShape.thickness / 16) + allShapes.length);
                    mainShape = null;
                    addShape();
                }

            }
        }

    }

    function addScore(value:Int) {

        score += value;

        if (scoreValueText != null) {
            scoreValueText.content = '' + score;
            scoreValueText.scale(1.25);
            scoreValueText.transition(0.2, scoreValueText -> {
                scoreValueText.scale(1);
            });
        }

    }

    function updatePointFromPlatform() {

        platform.visualToScreen(platform.width * 0.5, 60, _point);
        this.screenToVisual(_point.x, _point.y, _point);

    }

    function addShape() {

        var item = shapeConfigs.randomElement();

        var steps = item[0];
        var thickness = item[1];
        var color:Color = item[2];

        updatePointFromPlatform();

        var teeth = new TeethShape(
            steps,
            32, 16, 16 * thickness
        );
        teeth.depth = 10;
        allShapes.push(teeth);
        mainShape = teeth;
        teeth.pos(_point.x, _point.y);
        add(teeth);

        teeth.color = color;
        teeth.initNapePhysics(DYNAMIC);
        teeth.nape.body.cbTypes.add(teethCollisionType);

    }

    var aColor:Color = 0xFEC260;

    function PLAY_update(delta:Float) {

        // Im.begin('Info');
        // Im.text('platform.y=${Utils.round(platform.y, 2)}');
        // Im.text('height * 2=${Utils.round(height * 2, 2)}');
        // Im.end();

        if (platform.y > height * 2) {
            machine.state = GAME_OVER;
        }

        if (mainShape != null) {

            if (input.keyPressed(RIGHT) && !input.keyPressed(LEFT)) {
                mainShape.nape.body.velocity.x = xSpeed;
            }
            else if (input.keyPressed(LEFT) && !input.keyPressed(RIGHT)) {
                mainShape.nape.body.velocity.x = -xSpeed;
            }
            else {
                mainShape.nape.body.velocity.x = 0;
            }

            if (input.keyPressed(DOWN)) {
                mainShape.nape.body.velocity.y = Math.max(mainShape.nape.body.velocity.y, ySpeed);
            }

        }

        var toRemove = null;
        for (i in 0...allShapes.length) {
            var shape = allShapes[i];
            if (shape != mainShape && shape.y > height * 1.25) {
                if (toRemove == null) {
                    toRemove = [];
                }
                toRemove.push(shape);
                allShapes[i] = null;
            }
        }
        if (toRemove != null) {
            allShapes.removeNullElements();
            for (i in 0...toRemove.length) {
                toRemove[i].destroy();
            }
        }

    }

    function GAME_OVER_enter() {

        log.info('GAME OVER');
        if (mainShape != null) {
            mainShape.nape.body.velocity.x = 0;
            mainShape.nape.body.velocity.y = 0;
        }
        trace('press SPACE to try again');

        add(scoreTitleText);
        add(scoreValueText);

        scoreTitleText.pos(width * 0.5, height * 0.46);
        scoreValueText.pos(width * 0.5, height * 0.46 + 10);

        scoreTitleText.scale(2);
        scoreTitleText.scale(2 * 1.25);
        scoreTitleText.transition(0.2, scoreValueText -> {
            scoreTitleText.scale(2);
        });

        scoreValueText.scale(2 * 1.25);
        scoreValueText.transition(0.2, scoreValueText -> {
            scoreValueText.scale(2);
        });

        descText = new Text();
        descText.align = CENTER;
        descText.anchor(0.5, 0.5);
        descText.pointSize = 20;
        descText.depth = 20;
        add(descText);
        descText.pos(width * 0.5, height * 0.7);
        descText.content = 'PRESS SPACE TO TRY AGAIN';
        Timer.interval(descText, 0.5, function() {
            descText.visible = !descText.visible;
        });
        add(descText);

    }

    function GAME_OVER_update(delta:Float) {

        if (input.keyJustPressed(SPACE)) {
            machine.state = PLAY;
        }

    }

    function GAME_OVER_exit() {

        if (descText != null) {
            descText.destroy();
            descText = null;
        }

    }

    override function resize(width:Float, height:Float) {

        // Called everytime the scene size has changed

    }

    override function destroy() {

        // Perform any cleanup before final destroy

        super.destroy();

    }

}
