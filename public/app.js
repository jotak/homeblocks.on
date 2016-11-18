"use strict";
angular.module('homeblocks', [
    'ngRoute',
    'ngSanitize',
    'homeblocks.loginview',
    'homeblocks.mainview',
    'homeblocks.editview'
])
    .config(['$routeProvider', function ($routeProvider) {
        $routeProvider.otherwise({ redirectTo: '/u' });
    }]);
function computePositions(blocks) {
    var map = {};
    for (var i in blocks) {
        var block = blocks[i];
        map[block.posx + "," + block.posy] = block;
    }
    for (var i in blocks) {
        var block = blocks[i];
        block.N = map[block.posx + "," + (block.posy - 1)] !== undefined;
        block.S = map[block.posx + "," + (block.posy + 1)] !== undefined;
        block.E = map[(block.posx + 1) + "," + block.posy] !== undefined;
        block.W = map[(block.posx - 1) + "," + block.posy] !== undefined;
    }
}
function findBlockByPosition(blocks, x, y) {
    for (var i in blocks) {
        var block = blocks[i];
        if (block.posx == x && block.posy == y) {
            return block;
        }
    }
    return null;
}
function saveProfile($http, scope) {
    var deferred = Q.defer();
    $http.post('/api/user/' + scope.refUser + '/profile/' + scope.profile, scope.page).success(function() {
        deferred.resolve(true);
    }).error(function(err) {
        scope.message = 'Error: ' + err;
        deferred.reject(scope.message);
    });
    return deferred.promise;
}
function fillPageStyle(blocks, minPos) {
    computePositions(blocks);
    var id = 0;
    for (var i in blocks) {
        minPos = checkOutOfScreen(blocks[i], minPos);
    }
    for (var i in blocks) {
        fillBlockStyle(blocks[i], id++, minPos);
    }
}
function checkOutOfScreen(block, minPos) {
    var marginLeft = -FrontBlock.HALF_WIDTH + block.posx * FrontBlock.WIDTH;
    var marginTop = -FrontBlock.HALF_HEIGHT + block.posy * FrontBlock.HEIGHT;
    var x = window.innerWidth / 2 + marginLeft;
    var y = window.innerHeight / 2 + marginTop;
    if (x < minPos.x) {
        minPos.x = x;
    }
    if (y < minPos.y) {
        minPos.y = y;
    }
    return minPos;
}
function fillBlockStyle(block, id, minPos) {
    block.styleData = {
        marginLeft: -minPos.x - FrontBlock.HALF_WIDTH + block.posx * FrontBlock.WIDTH,
        marginTop: -minPos.y - FrontBlock.HALF_HEIGHT + block.posy * FrontBlock.HEIGHT,
        color: ((block.posx + block.posy) % 2) ? "#34495e" : "#020202",
        dx: 0,
        dy: 0
    };
    block.id = id;
    computeBlockStyle(block);
}
function computeBlockStyle(block) {
    var marginLeft = block.styleData.marginLeft + block.styleData.dx;
    var marginTop = block.styleData.marginTop + block.styleData.dy;
    block.style = "margin-left: " + marginLeft + "px; margin-top: " + marginTop + "px; background-color: " + block.styleData.color;
    block.NStyle = "margin-left: " + (marginLeft + 100) + "px; margin-top: " + marginTop + "px;";
    block.SStyle = "margin-left: " + (marginLeft + 100) + "px; margin-top: " + (marginTop + 200) + "px;";
    block.EStyle = "margin-left: " + (marginLeft + 200) + "px; margin-top: " + (marginTop + 100) + "px;";
    block.WStyle = "margin-left: " + marginLeft + "px; margin-top: " + (marginTop + 100) + "px;";
    return block.style;
}
function isFreePosition(pos, page) {
    for (var i in page.blocks) {
        var block = page.blocks[i];
        if (pos.x == block.posx && pos.y == block.posy) {
            return false;
        }
    }
    return true;
}
function findFreePosition(page) {
    // Spiral algorithm
    var deep = 0;
    var fRounds = function(d) { return (2*d+1) * (2*d+1); };
    var nRounds = fRounds(deep);
    var t = 0;
    var fpos = function(x,y) { return {x: x, y: y}};
    var pos = fpos(0, 0);
    var ops = [
        function(p) {return fpos(p.x+1, p.y) },
        function(p) {return fpos(p.x, p.y+1) },
        function(p) {return fpos(p.x-1, p.y) },
        function(p) {return fpos(p.x, p.y-1) }];
    var curOp = 0;
    while (!isFreePosition(pos, page)) {
        t++;
        if (t == nRounds) {
            deep++;
            nRounds = fRounds(deep);
        }
        var testPos = ops[curOp](pos);
        if (Math.abs(testPos.x) > deep || Math.abs(testPos.y) > deep) {
            // Invalid operation; increment op cursor
            curOp = (curOp + 1) % 4;
            pos = ops[curOp](pos);
        } else {
            pos = testPos;
        }
        if (t > 999) {
            console.error("WTF you want to kill me?!");
            break;
        }
    }
    return pos;
}
function mergeInPage(page, blocks) {
    for (var i in blocks) {
        var pos = findFreePosition(page);
        blocks[i].posx = pos.x;
        blocks[i].posy = pos.y;
        page.blocks.push(blocks[i]);
    }
}