"use strict";
angular.module('homeblocks.mainview', ['ngRoute'])
    .config(['$routeProvider', function ($routeProvider) {
        $routeProvider.when('/v/:username', {
            templateUrl: 'mainview.html',
            controller: 'mainViewCtrl'
        });
    }]).controller("mainViewCtrl", ['$scope', '$http', '$routeParams', '$rootScope', '$location', function ($scope, $http, $routeParams, $rootScope, $location) {
        $rootScope.title = $routeParams.username + "@homeblocks";
        $http.get('/api/profile/' + $routeParams.username)
            .success(function (profile) {
            $scope.profile = profile;
            $scope.username = $routeParams.username;
            $scope.blocks = profile.page.blocks;
            $scope.minPos = { x: 0, y: 0 };
            fillPageStyle($scope.blocks, $scope.minPos);
            initMainListeners($scope, $location, $http);
        })
            .error(function (data) {
            console.log('Error: ' + data);
        });
    }]).directive("pressEnter", function () {
    return function (scope, element, attrs) {
        element.bind("keydown keypress", function (event) {
            if (event.which === 13) {
                scope.$apply(function () {
                    scope.$eval(attrs.myEnter);
                });
                event.preventDefault();
            }
        });
    };
}).directive('trustedUrl', function ($sce) {
    return {
        restrict: 'A',
        scope: {
            src: '='
        },
        replace: true,
        template: function (element, attrs, scope) {
            return '<' + attrs.type + ' ng-src="{{ url }}" controls></' + attrs.type + '>';
        },
        link: function (scope) {
            scope.$watch('src', function (newVal, oldVal) {
                if (newVal !== undefined) {
                    scope.url = $sce.trustAsResourceUrl(newVal);
                }
            });
        }
    };
});
function initMainListeners($scope, $location, $http) {
    $scope.editMode = function (password) {
        $scope.token = "";
        $http.post('/api/auth', { username: $scope.username, password: password })
            .success(function (token) {
                $location.path("/e/" + $scope.username + "/" + token);
            })
            .error(function (err) {
                console.error('Error: ' + err);
                $scope.profile.message = 'Error: ' + err;
            });
    };
    $scope.onNew = function (username, password) {
        $http.put('/api/profile', { username: username, password: password, page: [] })
            .success(function (token) {
            $location.path("/e/" + username + "/" + token);
        })
            .error(function (err) {
            console.error(err);
            $scope.profile.message = err;
        });
    };
    $scope.onDuplicate = function (username, password) {
        $http.put('/api/profile', { username: username, password: password, page: [] })
            .success(function (token) {
                $scope.profile.username = username;
                $scope.profile.password = password;
                saveProfile($http, token, $scope.profile).then(function () {
                    $location.path("/v/" + username);
                }).fail(function (err) {
                    console.error(err);
                    $scope.profile.message = err;
                }).done();
                $scope.profile.password = "";
            })
            .error(function (err) {
                console.error(err);
                $scope.profile.message = err;
            });
    };
    $scope.onUpload = function (uploaded) {
        $scope.profile = eval('(' + uploaded + ')');
        $http.put('/api/profile', { username: $scope.profile.username, password: $scope.profile.password })
            .success(function (token) {
                saveProfile($http, token, $scope.profile).then(function () {
                    $location.path("/v/" + $scope.profile.username);
                }).fail(function (err) {
                    console.error(err);
                    $scope.profile.message = err;
                }).done();
                $scope.profile.password = "";
            })
            .error(function (err) {
                console.error(err);
                $scope.profile.message = err;
            });
    };
    $scope.onClickNew = function () {
        $scope.showNew = !$scope.showNew;
        setTimeout(function () {
            document.getElementById('newName').focus();
        }, 30);
    };
    $scope.onClickEdit = function () {
        $scope.showEdit = !$scope.showEdit;
        setTimeout(function () {
            document.getElementById('editPwd').focus();
        }, 30);
    };
    $scope.onClickDuplicate = function () {
        $scope.showDuplicate = !$scope.showDuplicate;
        setTimeout(function () {
            document.getElementById('dupName').focus();
        }, 30);
    };
}
