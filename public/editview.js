"use strict";
angular.module('homeblocks.editview', ['ngRoute'])
    .config(['$routeProvider', function ($routeProvider) {
        $routeProvider.when('/e/:username/:token', {
            templateUrl: 'editview.html',
            controller: 'editViewCtrl'
        });
    }])
    .controller("editViewCtrl", ['$scope', '$http', '$routeParams', '$rootScope', '$location', '$document', function ($scope, $http, $routeParams, $rootScope, $location, $document) {
        $rootScope.title = $routeParams.username + "@homeblocks";
        $http.get('/api/profile/' + $routeParams.username)
            .success(function (profile) {
            $scope.profile = profile;
            $scope.username = $routeParams.username;
            $scope.token = $routeParams.token;
            $scope.blocks = profile.page.blocks;
            $scope.minPos = { x: 0, y: 0 };
            fillPageStyle($scope.blocks, $scope.minPos);
            initEditListeners($scope, $location, $http, $document);
        })
            .error(function (data) {
            console.log('Error: ' + data);
        });
    }]);
function initEditListeners($scope, $location, $http, $document) {
    $scope.viewMode = function () {
        $scope.token = "";
        $location.path("/v/" + $scope.username);
    };
    $scope.onClickBlockTitle = function (block, focusId) {
        block.editTitle = true;
        setTimeout(function () {
            document.getElementById(focusId).focus();
        }, 30);
    };
    $scope.onClickLink = function (link, focusId) {
        link.editing = true;
        setTimeout(function () {
            document.getElementById(focusId).focus();
        }, 30);
    };
    $scope.onSaveLink = function (link) {
        link.editing = false;
        saveProfile($http, $scope.token, $scope.profile);
    };
    $scope.onCreateLink = function (block) {
        var link = {
            title: "",
            url: "http://",
            description: "",
            editing: true
        };
        block.links.push(link);
        saveProfile($http, $scope.token, $scope.profile);
    };
    $scope.onDeleteLink = function (block, index) {
        block.links.splice(index, 1);
        saveProfile($http, $scope.token, $scope.profile);
    };
    $scope.onLinkUp = function (block, index) {
        var tmp = block.links[index - 1];
        block.links[index - 1] = block.links[index];
        block.links[index] = tmp;
        saveProfile($http, $scope.token, $scope.profile);
    };
    $scope.onSaveBlock = function (block) {
        block.editTitle = false;
        saveProfile($http, $scope.token, $scope.profile);
    };
    $scope.onCreateBlock = function (x, y, type) {
        var block = createEmptyBlock(x, y, type);
        if (block != null) {
            $scope.blocks.push(block);
            fillPageStyle($scope.blocks, $scope.minPos);
            saveProfile($http, $scope.token, $scope.profile);
        }
    };
    $scope.onCreateCopyBlock = function (x, y) {
        $scope.blocks.push({
            posx: x,
            posy: y,
            type: "copy"
        });
        fillPageStyle($scope.blocks, $scope.minPos);
    };
    $scope.onSwapBlocks = function (b1, b2x, b2y) {
        var b2 = findBlockByPosition($scope.blocks, b2x, b2y);
        b2.posx = b1.posx;
        b2.posy = b1.posy;
        b1.posx = b2x;
        b1.posy = b2y;
        fillPageStyle($scope.blocks, $scope.minPos);
        saveProfile($http, $scope.token, $scope.profile);
    };
    $scope.onDeleteBlock = function (block) {
        var index = $scope.blocks.indexOf(block);
        if (index >= 0) {
            $scope.blocks.splice(index, 1);
            fillPageStyle($scope.blocks, $scope.minPos);
            saveProfile($http, $scope.token, $scope.profile);
        }
    };
    $scope.onSearchBlocks = function (block) {
        $http.get('/api/profile/' + block.fromProfile + "/blocknames")
            .success(function (blockNames) {
            block.fromBlocks = blockNames;
        })
            .error(function (data) {
            console.log('Error: ' + data);
        });
    };
    $scope.onCopyBlock = function (block) {
        $http.get('/api/profile/' + block.fromProfile + "/block/" + block.selected)
            .success(function (fromBlock) {
            fromBlock.posx = block.posx;
            fromBlock.posy = block.posy;
            var index = $scope.blocks.indexOf(block);
            $scope.blocks[index] = fromBlock;
            fillPageStyle($scope.blocks, $scope.minPos);
            saveProfile($http, $scope.token, $scope.profile);
        })
            .error(function (data) {
            console.log('Error: ' + data);
        });
    };
}
function createEmptyBlock(x, y, type) {
    var block = new FrontBlock();
    block.posx = x;
    block.posy = y;
    block.type = type;
    if (type == "links" || type == "audio" || type == "video") {
        block.links = [];
    }
    else {
        console.log("Type " + type + " not implemented (yet?)");
        return null;
    }
    return block;
}
