"use strict";
angular.module('homeblocks', [
    'ngRoute',
    'ngSanitize',
    'homeblocks.mainview',
    'homeblocks.editview'
])
    .config(['$routeProvider', function ($routeProvider) {
        $routeProvider.otherwise({ redirectTo: '/v/sandbox' });
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
function saveProfile($http, token, profile) {
    var deferred = Q.defer();
    $http.post('/api/profile', { token: token, profile: profile })
        .success(function (response) {
        deferred.resolve(true);
    })
        .error(function (err) {
        deferred.reject('Error: ' + err);
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
