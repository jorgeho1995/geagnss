/*!
 * gea v1.0.4
 * Materialize theme
 * http://materializecss.com/themes.html
 * Personal Use License
 * by Alan Chang
 */

(function ($) {
  $(document).ready(function(){

    /********************
     * Helper Functions *
     ********************/
    var debounce = function (fn, duration) {
      var timeout;
      return function () {
        var args = Array.prototype.slice.call(arguments),
            ctx = this;

        clearTimeout(timeout);
        timeout = setTimeout(function () {
          fn.apply(ctx, args);
        }, duration);
      };
    };

    /**
     * Returns duration function for scrollmagic.
     * @param {String} dataDuration
     * @param {String} defaultDuration
     * @param {Integer} multiple
     * @returns {Function}
     */
    var parseDuration = function(dataDuration, defaultDuration, multiple) {
      var string = dataDuration || defaultDuration;
      var multiple = multiple || 1;
      var parsedInt = parseInt(string);

      if (string.indexOf('%') >= 0) {
        var ratio = parsedInt / 100;
        return function() {
          return window.innerHeight * ratio * multiple;
        }
      } else if (parsedInt !== NaN) {
        return function() {
          return parsedInt * multiple;
        }
      } else {
        return function() {
          return window.innerHeight * multiple;
        }
      }
    };

    /**
     * Returns dynamic duration based on progress of scroll
     * @param {Integer} minDuration
     * @param {Integer} scrollDuration
     * @param {Integer} originalOffset
     * @returns {[Integer,Integer]} [Offset, Duration]
     */
    var dynamicOffsetAndDuration = function(minDuration, scrollDuration, originalOffset) {
      var diff = $(window).scrollTop() - originalOffset;
      var ratio = 1 - (diff / scrollDuration);
      var scrollDistance = scrollDuration;
      var offset = originalOffset + scrollDistance;
      var duration = Math.max(ratio * scrollDistance, minDuration);
      return [offset, duration];
    };

    /**
     * Reset tween or timeline variables (used for resize or disable)
     * @param {Object} tween
     * @param {Boolean} isTimeline
     */
    var resetTween = function(tween, isTimeline) {
      if (!!tween) {
        tween.progress(0);
        tween.invalidate();

        if (isTimeline) {
          var tweens = tween.getChildren();
          for (var k = 0; k < tweens.length; k++) {
            TweenMax.set(tweens[k].target, {clearProps: "all"});
          }
        } else {
          TweenMax.set(tween.target, {clearProps: "all"});
        }
      }
    };

    /**
     * Checks if element hasClass in a given string array.
     * @param {jQuery} el - The jQuery element we are checking.
     * @param {Array<String>} arr - The array of correct classes.
     */
    var hasClassInArray = function(el, arr) {
      for (var i = 0; i < arr.length; i++) {
        if (el.hasClass(arr[i])) {
          return true;
        }
      }
      return false;
    };

    /* End Helper Functions */


    // Read more button.
    $('.read-more').off('click.read-more').on('click.read-more', function () {
      var sectionHeight = $(this).closest('.section').outerHeight();
      var offset = sectionHeight || window.innerHeight;
      $('html, body').animate({scrollTop: offset }, 1000);
    });

    // Disabled read more button.
    var disabledReadMoreScroll = function(el, ancestorSelector) {
      var ancestor = el.closest(ancestorSelector);
      var height = ancestor.outerHeight();
      var offset = ancestor.offset().top + height;
      $('html, body').animate({scrollTop: offset }, 1000);
    };
    $('.horizontal-half-wrapper .read-more').off('click.read-more').on('click.read-more', function (e) {
      disabledReadMoreScroll($(this), '.horizontal-half-wrapper');
    });
    $('.flip-out-intro .read-more').off('click.read-more').on('click.read-more', function (e) {
      disabledReadMoreScroll($(this), '.flip-out-intro');
    });


    /***************
     * ScrollMagic *
     ***************/

    // init controller
    var controller = new ScrollMagic.Controller();

    // Transition definitions
    var transitionTypes = {
      'blogTitle': 'blogTitle',
      'horizontalHalf': 'horizontalHalf',
      'zoomOut': 'zoomOut',
      'phoneWall': 'phoneWall',
      'flipOut': 'flipOut',
      'circleReveal': 'circleReveal',
      'shuffleOver': 'shuffleOver',
      'shuffleUnder': 'shuffleUnder',
      'staggeredElement': 'staggeredElement',
      'elementTransition': 'elementTransition',
    }

    // Element transitions selectors
    var transformArray =
      ['scale',
       'up',
       'right',
       'down',
       'left',
       'rotate-y',
       'rotate-x'];
    var propertyArray =
      ['fade',
       'lid-tilt',
       'phone-arc'];
    var buildTransitionSelectors = function(arr) {
      var selector = '';
      for (var i = 0; i < arr.length; i++) {
        if (i > 0) {
          selector += ', ';
        }
        selector += '.'+arr[i]+'-in, ';
        selector += '.'+arr[i]+'-in-out, ';
        selector += '.'+arr[i]+'-out, ';
        selector += '.'+arr[i]+'-out-in';
      }
      return selector;
    };
    var transformTransitionSelector = buildTransitionSelectors(transformArray);
    var transformTransitionsArray = transformTransitionSelector.replace(/[.]+/g, '').split(', ');
    var elTransitionSelector = transformTransitionSelector + ', ' + buildTransitionSelectors(propertyArray);
    var elTransitionArray = elTransitionSelector.replace(/[.]+/g, '').split(', ');
    var oneWayTransitionsArray = elTransitionArray.filter(function(val) {
      return val.indexOf('in-out') < 0 && val.indexOf('out-in') < 0;
    });

    // keep track of all live tweens / scenes for resize event.
    var currentTransitions = {};
    var transitionId = 0;

    // Scroll Transition Plugin Methods
    var methods = {
      init : function(options) {
        var defaults = {
          duration: undefined,
          responsiveThreshold: 768,
          staggeredDelay: .8,
          reset: true
        };
        options = $.extend(defaults, options);

        var urlObjectId = window.location.hash.substring(1);

        return this.each(function(i) {
          var $this = $(this);
          var duration = $this.attr('data-duration') || options.duration;
          var responsiveThreshold = $this.attr('data-responsivethreshold') || options.responsiveThreshold;
          var staggeredDelay = $this.attr('data-staggereddelay') || options.staggeredDelay;
          var reset = options.reset;

          // Don't init if child of staggered element transition
          if ($this.parent('.staggered-transition-wrapper').length &&
              hasClassInArray($this, elTransitionArray)) {
            return;
          }

          var firstTime = false;
          var dataId = $this.attr('data-id');
          if (!dataId) {
            transitionId++;
            dataId = transitionId;
            $this.attr('data-id', dataId);
            firstTime = true;
          }

          // Shared variables
          var navbar = $('nav.navbar').first();
          var originalOffset = $this.offset().top;

          // Shared duration functions
          var getElHeight = parseDuration(duration, $this.outerHeight() + 'px');
          var getHalfWindowHeight = parseDuration(duration, '50%');
          var getWindowHeight = parseDuration(duration, '100%');
          var getOneAndHalfWindowHeight = parseDuration(duration, '150%');

          // Shared navbar functions
          var toggleSolid = function(e) {
            if (e.scrollDirection === 'FORWARD') {
              navbar.addClass('solid');
            } else {
              navbar.removeClass('solid');
            }
          };
          var toggleSolidFixed = function(e) {
            if (e.scrollDirection === 'FORWARD') {
              navbar.removeClass('absolute');
              navbar.addClass('solid');
            } else {
              navbar.addClass('absolute');
              navbar.removeClass('solid');
            }
          };


          // Only initialize if past responsive threshold
          if (window.innerWidth >= responsiveThreshold) {
            /**************
             * BLOG TITLE *
             **************/
            if ($this.hasClass('title-transition')) {
              var fadeWrapper = $this.find('.fade-transition');

              // build tween
              var tween = TweenMax.to(fadeWrapper, 1, {scale: "0", opacity: 0, ease: Power2.easeIn});

              // build scene
              var scene = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getHalfWindowHeight})
                      .setTween(tween)
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.blogTitle,
                sceneTweenPairs: [{scene: scene, tween: tween}]
              };

            /************
             * ZOOM OUT *
             ************/
            } else if ($this.hasClass('zoom-out-intro')) {
              var getThirdOfDuration = parseDuration(duration, '150%', .33);

              $this.find('.read-more').off('click.read-more').on('click.read-more', function () {
                var scrollDuration = getOneAndHalfWindowHeight() + window.innerHeight;
                var offsetAndDuration = dynamicOffsetAndDuration(300, scrollDuration, originalOffset);
                $('html, body').animate({scrollTop: offsetAndDuration[0] }, offsetAndDuration[1]);
              });

              var laptop = $this.find('.laptop-preview-sizer');
              var header = $this.find('.header-wrapper');

              // build tween
              var tweenZoomOut = TweenMax.to(laptop, 1, {scale: .5, ease: Power2.easeInOut});
              var tweenFadeHeader = TweenMax.to(header, 1, {opacity: 0, ease: Power2.easeInOut});
              var tweenFadeNavbar = TweenMax.to(navbar, 1, {opacity: 0, ease: Power2.easeInOut});

              // build scene
              var onEndOneCallback = function(e) {
                if (e.scrollDirection === 'FORWARD') {
                  navbar.addClass('active');
                } else {
                  navbar.removeClass('active');
                }
              };

              var onEndTwoCallback = function(e) {
                if (e.scrollDirection === 'FORWARD') {
                  navbar.addClass('solid fade-in-out no-tween');
                  setTimeout(function() {
                    navbar.css('opacity', '');
                  }, 0);
                } else {
                  navbar.removeClass('solid fade-in-out no-tween');
                  setTimeout(function() {
                    navbar.css('opacity', 0);
                  }, 0);
                }
              };

              var scene = new ScrollMagic.Scene({duration: getOneAndHalfWindowHeight})
                      .setTween(tweenZoomOut)
                      .setPin($this[0])
                      .on('end', onEndOneCallback)
                      .addTo(controller);
              var scene2 = new ScrollMagic.Scene({duration: getThirdOfDuration})
                      .setTween(tweenFadeHeader)
                      .on('end', onEndTwoCallback)
                      .addTo(controller);
              var scene3 = new ScrollMagic.Scene({duration: getThirdOfDuration})
                      .setTween(tweenFadeNavbar)
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.zoomOut,
                sceneTweenPairs: [{scene: scene, tween: tweenZoomOut}, {scene: scene2, tween: tweenFadeHeader},{scene: scene3, tween: tweenFadeNavbar}]
              };

            /**************
             * PHONE WALL *
             **************/
            } else if ($this.hasClass('phone-wall-intro')) {
              $this.find('.read-more').off('click.read-more').on('click.read-more', function () {
                var scrollDuration = getWindowHeight();
                var offsetAndDuration = dynamicOffsetAndDuration(300, scrollDuration, originalOffset);
                $('html, body').animate({scrollTop: offsetAndDuration[0] }, offsetAndDuration[1]);
              });

              var columnOne = $this.find('.column-one');
              var columnTwo = $this.find('.column-two');
              var columns = columnOne.add(columnTwo);
              var header = $this.find('.header-wrapper');

              // build tween
              var tweenPhoneTimeline = new TimelineMax();

              // build scene
              columns.each(function() {
                var col = $(this);
                var phones = col.find('.phone-preview-sizer');
                var len = phones.length;
                phones.each(function(i) {
                  var mult = len - i;
                  var randDelay = (Math.round( ((Math.random() / 2) + .5) * 10 ) / 10) * mult;

                  tweenPhoneTimeline.to(this, 1, {className: "+=active", ease: Power2.easeInOut}, randDelay);
                });
              });

              var scene = new ScrollMagic.Scene({duration: getWindowHeight})
                      .setTween(tweenPhoneTimeline)
                      .setPin($this[0])
                      .on('end', toggleSolidFixed)
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.phoneWall,
                sceneTweenPairs: [{scene: scene, tween: tweenPhoneTimeline, isTimeline: true}]
              };

            /************
             * FLIP OUT *
             ************/
            } else if ($this.hasClass('flip-out-intro')) {
              var getTwiceDuration = parseDuration(duration, '100%', 2);

              $this.find('.read-more').off('click.read-more').on('click.read-more', function (e) {
                e.stopPropagation();
                var scrollDuration = getWindowHeight();
                var offsetAndDuration = dynamicOffsetAndDuration(300, scrollDuration, originalOffset);
                $('html, body').animate({scrollTop: offsetAndDuration[0] }, offsetAndDuration[1]);
              });

              var fixedWrapper = $this.find('.fixed-wrapper');
              var header = $this.find('.header-wrapper');
              var isStart = $this.is($('.flip-out-intro').first()) && $this.scrollTop() === 0;

              // Event handlers
              fixedWrapper.on('click', function() {
                var offsetTop = $this.offset().top;
                var diff = Math.abs($(window).scrollTop() - offsetTop);
                var ratio = diff / window.innerHeight;
                var duration = Math.max(ratio * 1200, 200);
                $('html, body').animate({scrollTop: offsetTop }, duration);
              });


              // Build tweens and timelines
              var tween;
              var isTimeline = false;
              if (isStart) {
                tween = TweenMax.to(fixedWrapper, 1, {scale: .4, rotationX: 110, y: '-40%'});
              } else {
                isTimeline = true;
                tween = new TimelineMax();
                tween.set(fixedWrapper, {scale: .3, rotationX: 110, y: '-100%'} );
                tween.to(fixedWrapper, 1, {scale: 1, rotationX: 0, y: '0%'});
                tween.to(fixedWrapper, 1, {scale: .4, rotationX: 110, y: '-40%'});
              }


              // build scene
              var scene;
              if (isStart) {
                scene = new ScrollMagic.Scene({duration: getWindowHeight})
                        .setTween(tween)
                        .addTo(controller);
              } else {
                scene = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onEnter', duration: getTwiceDuration})
                        .setTween(tween)
                        .addTo(controller);
              }

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.flipOut,
                sceneTweenPairs: [{scene: scene, tween: tween, isTimeline: isTimeline}]
              };

            /*****************
             * CIRCLE REVEAL *
             *****************/
            } else if ($this.hasClass('circle-reveal-intro')) {
              // Read more
              $this.find('.read-more').off('click.read-more').on('click.read-more', function (e) {
                var index = $(this).closest('.circle-reveal-wrapper').index('.circle-reveal-wrapper') + 1;
                $('html, body').animate({scrollTop: originalOffset + (window.innerHeight * index) }, 800);
              });

              var tweenCircleTimeline = new TimelineMax();
              var tweenFadeTimeline = new TimelineMax();
              var len = $('.circle-reveal-wrapper').length;
              var backgroundLayer = $this.find('.background-layer');

              var getFullHeight = function() {
                return window.innerHeight * len;
              }

              $this.find('.circle-reveal-wrapper').each(function(i) {
                var wrapper = $(this);
                var header = wrapper.find('.header-wrapper');
                var circle = wrapper.find('.circle-background');
                wrapper.css('z-index', len - i);

                // build tween
                tweenCircleTimeline.to(circle, 1, {scale: 0, ease: Power2.easeInOut});
                tweenFadeTimeline
                  .to(header, .5, {opacity: 0, ease: Power2.easeInOut,
                    onComplete: function() {
                      if (wrapper.next('.circle-reveal-wrapper').find('.circle-background').hasClass('white')) {
                        navbar.addClass('dark');
                      } else {
                        navbar.removeClass('dark');
                      }
                      wrapper.css('pointer-events', 'none');
                    },
                    onReverseComplete: function() {
                      var prevWrapper = wrapper.prev('.circle-reveal-wrapper').length ? wrapper.prev('.circle-reveal-wrapper') : wrapper;
                      if (prevWrapper.find('.circle-background').hasClass('white')) {
                        navbar.addClass('dark');
                      } else {
                        navbar.removeClass('dark');
                      }
                      wrapper.css('pointer-events', '');
                    }
                  })
                  .to({}, .5, {});
              });
              // build scene
              var scene = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getFullHeight})
                      .setTween(tweenCircleTimeline)
                      .setPin($this[0])
                      .addTo(controller);
              var scene2 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getFullHeight})
                      .setTween(tweenFadeTimeline)
                      .on('end', function(e) {
                        toggleSolid(e);
                        if (e.scrollDirection === 'FORWARD') {
                          backgroundLayer.addClass('end');
                        } else {
                          backgroundLayer.removeClass('end');
                        }
                      })
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.circleReveal,
                sceneTweenPairs: [{scene: scene, tween: tweenCircleTimeline, isTimeline: true}, {scene: scene2, tween: tweenFadeTimeline, isTimeline: true}]
              };

            /*******************
             * HORIZONTAL HALF *
             *******************/
            } else if ($this.hasClass('horizontal-half-transition')) {
              // Read more
              $this.find('.read-more').off('click.read-more').on('click.read-more', function (e) {
                var index = $(this).closest('.horizontal-half-wrapper').index('.horizontal-half-wrapper') + 1;
                $('html, body').animate({scrollTop: originalOffset + (window.innerHeight * 2 * index) }, 1200);
              });

              var device = $this.find('.phone-preview-sizer');
              var wrappers = $this.find('.horizontal-half-wrapper');


              // build scene
              var getFullHeight = function() {
                return window.innerHeight * ((wrappers.length * 2) - 1);
              }


              var tweenDeviceTimeline = new TimelineMax();
              var tweenBackgroundTimeline = new TimelineMax();
              var tweenFadeTimeline = new TimelineMax();

              wrappers.each(function(i) {
                var direction = $(this).hasClass('right-side') ? 'right' : 'left';
                var activeDeviceObj = {ease: Power4.easeInOut};
                var activeBackgroundObj = {ease: Power3.easeInOut};
                var activeFadeObj = {opacity: 1, ease: Power2.easeInOut, delay: .5};
                var backgroundObj = {ease: Power3.easeInOut};
                var fadeObj = {opacity: 0, ease: Power2.easeInOut};

                var switchActiveDevice = function(j) {
                   var images = device.find('.image-container');
                   var active = images.eq(j);
                   if (active.length) {
                     images.removeClass('active');
                     active.addClass('active');
                   }
                };

                var header = $(this).find('.header-wrapper');
                var headerBg = $(this).find('.header-background');

                if (i === 0) {
                  tweenBackgroundTimeline.set($(this), {zIndex: 1});
                }

                if (!$(this).hasClass('active')) {
                  activeDeviceObj.left = direction === 'right' ? '25%' : '75%';
                  activeDeviceObj.onStart = function() {
                    switchActiveDevice(i)
                  };
                  activeDeviceObj.onReverseComplete = function() {
                    switchActiveDevice(i-1)
                  }
                  tweenDeviceTimeline.to(device, .8, activeDeviceObj);
                  tweenDeviceTimeline.to({}, .2, {});
                  tweenBackgroundTimeline.set($(this), {zIndex: 1});
                  activeBackgroundObj[direction] = '+=100%';
                  tweenBackgroundTimeline.to(headerBg, 1, activeBackgroundObj);
                  activeFadeObj[direction] = '+=50px';
                  tweenFadeTimeline.to(header, 0.5, activeFadeObj);
                }

                tweenDeviceTimeline.to(device, .8, {left: '50%', ease: Power4.easeInOut, delay: .2});
                backgroundObj[direction] = '-=100%';
                tweenBackgroundTimeline.to(headerBg, 1, backgroundObj);
                tweenBackgroundTimeline.set($(this), {zIndex: -1});
                fadeObj[direction] = '-=50px';
                tweenFadeTimeline.to(header, 0.5, fadeObj);
                tweenFadeTimeline.to({}, .5, {});
              });

              var scene1 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getFullHeight})
                      .setTween(tweenDeviceTimeline)
                      .setPin($this[0])
                      .addTo(controller);
              var scene2 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getFullHeight})
                      .setTween(tweenBackgroundTimeline)
                      .addTo(controller);
              var scene3 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getFullHeight})
                      .setTween(tweenFadeTimeline)
                      .on('end', toggleSolidFixed)
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.horizontalHalf,
                sceneTweenPairs: [
                  {scene: scene1, tween: tweenDeviceTimeline, isTimeline: true},
                  {scene: scene2, tween: tweenBackgroundTimeline, isTimeline: true},
                  {scene: scene3, tween: tweenFadeTimeline, isTimeline: true}
                ]
              };

            /****************
             * SHUFFLE OVER *
             ****************/
            } else if ($this.hasClass('shuffle-over-transition')) {
              var getDuration = parseDuration(duration, '100%');
              var heightOffset = $this.innerHeight() - window.innerHeight;

              // build scene
              var scene1 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onLeave', duration: getDuration, offset: heightOffset})
                      .setClassToggle($this[0], "z-depth-1")
                      .setPin($this[0], {pushFollowers: false})
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.shuffleOver,
                sceneTweenPairs: [{scene: scene1}]
              };

            /*****************
             * SHUFFLE UNDER *
             *****************/
            } else if ($this.hasClass('shuffle-under-transition')) {
              // build scene

              var scene1 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onEnter', duration: getElHeight })
                      .on('end', function () { $this.toggleClass('shuffle-under-end'); })
                      .setClassToggle($this[0], 'shuffle-under-active')
                      .setPin($this[0], {pushFollowers: false})
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.shuffleUnder,
                sceneTweenPairs: [{scene: scene1}]
              };

            /*********************************
             * STAGGERED ELEMENT TRANSITIONS *
             *********************************/
            } else if ($this.hasClass('staggered-transition-wrapper')) {
              var elementTransitions = $this.find(elTransitionSelector);
              var tweenElementTimeline = new TimelineMax();
              elementTransitions.each(function() {
                tweenElementTimeline.to(this, 1, {className: "+=active", ease: Power3.easeInOut}, '-='+staggeredDelay);
              });

              var scene1 = new ScrollMagic.Scene({triggerElement: $this[0], triggerHook: 'onEnter', duration: getElHeight})
                      .setTween(tweenElementTimeline)
                      .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.staggeredElement,
                sceneTweenPairs: [{scene: scene1, tween: tweenElementTimeline, isTimeline: true}]
              };

            /***********************
             * ELEMENT TRANSITIONS *
             ***********************/
            } else if (hasClassInArray($this, elTransitionArray)) {
               // For transforms, use parent as trigger wrapper to avoid movement of trigger.
              var triggerEl = $this[0];
              if (hasClassInArray($this, transformTransitionsArray)) {
                triggerEl = $this.parent()[0];
              }

              var reverse = !hasClassInArray($this, oneWayTransitionsArray);

              var tween = TweenMax.to($(this), 1, {className: "+=active", ease: Power3.easeInOut});
              var scene1 = new ScrollMagic.Scene({triggerElement: triggerEl, triggerHook: 'onEnter', duration: getElHeight, offset: 100, reverse: reverse})
                .setTween(tween)
                .addTo(controller);

              // Add to list
              currentTransitions[dataId] = {
                type: transitionTypes.elementTransition,
                sceneTweenPairs: [{scene: scene1, tween: tween}]
              };
            }

            currentTransitions[dataId].class = $this.attr('class');
          } else {
            // Disable under responsive threshold
            $this.attr('data-disabled', true);
          }


          // Resize
          var debouncedResize = debounce(function() {
            var windowWidth = window.innerWidth;
            var disabled = $this.attr('data-disabled') === 'true';

            if (disabled) {
              if (window.innerWidth >= responsiveThreshold) {
                // Enable over responsive threshold
                $this.attr('data-disabled', false);
                $this.scrollTransition({reset: false});

              }
            } else {
              var type = currentTransitions[dataId].type;
              var sceneTweenPairs = currentTransitions[dataId].sceneTweenPairs;

              for (var j = 0; j < sceneTweenPairs.length; j++) {
                var tween = sceneTweenPairs[j].tween;
                var isTimeline = sceneTweenPairs[j].isTimeline === true;
                var scene = sceneTweenPairs[j].scene;

                if (window.innerWidth < responsiveThreshold) {
                  // Disable under responsive threshold
                  $this.attr('data-disabled', true);
                }

                resetTween(tween, isTimeline);
                scene.destroy(true);
              }

              if ($this.attr('data-disabled') !== 'true') {
                $this.scrollTransition({reset: false});
              }
            }

          }, 400);

          $(window)
            .off('resize.scrollTransition' + dataId)
            .on('resize.scrollTransition' + dataId, debouncedResize);
        });
      },
      // Custom methods.
      destroy : function() {
        var $this = $(this);
        var dataId = $this.attr('data-id');

        var type = currentTransitions[dataId].type;
        var sceneTweenPairs = currentTransitions[dataId].sceneTweenPairs;

        for (var j = 0; j < sceneTweenPairs.length; j++) {
          var tween = sceneTweenPairs[j].tween;
          var isTimeline = sceneTweenPairs[j].isTimeline === true;
          var scene = sceneTweenPairs[j].scene;

          $this.attr('data-disabled', true);
          resetTween(tween, isTimeline);
          scene.destroy(true);
        }

        // Reset plugin values
        $this.attr('data-id', '');
        delete currentTransitions[dataId];
        $(window).off('resize.scrollTransition' + dataId);
      },
    };

    // Scroll Transition Plugin
    $.fn.scrollTransition = function(methodOrOptions) {
      if ( methods[methodOrOptions] ) {
        return methods[ methodOrOptions ].apply( this, Array.prototype.slice.call( arguments, 1 ));
      } else if ( typeof methodOrOptions === 'object' || ! methodOrOptions ) {
        // Default to "init"
        return methods.init.apply( this, arguments );
      } else {
        $.error( 'Method ' +  methodOrOptions + ' does not exist on jQuery.scrollTransition' );
      }
    }; // Plugin end


    // Init Scroll Transitions
    $('.title-transition').scrollTransition();
    $('.zoom-out-intro').scrollTransition();
    $('.phone-wall-intro').scrollTransition();
    $('.flip-out-intro').scrollTransition();
    $('.circle-reveal-intro').scrollTransition();
    $('.horizontal-half-transition').scrollTransition();
    $('.shuffle-over-transition').scrollTransition();
    $('.shuffle-under-transition').scrollTransition();
    $('.staggered-transition-wrapper').scrollTransition();
    $(elTransitionSelector).scrollTransition();


    // Navbar scroll transitions
    $(window).on('scroll.navbar', function () {
      var navbar = $('nav.navbar').first();
      if (navbar.hasClass('navbar-solid-transition')) {
        if ($(window).scrollTop() > 0) {
          navbar.addClass('solid');
        } else {
          navbar.removeClass('solid');
        }
      }
    });


    // Masonry Blog.
    var $masonry = $('.masonry-grid');
    if ($masonry.length) {
      $masonry.imagesLoaded(function() {
        $masonry.masonry({
          columnWidth: '.col',
          itemSelector: '.col'
        });
      });
    }


    // Google Maps
    if (typeof google === 'object' && typeof google.maps === 'object') {
      function initMap(mapEl, roadColor, landColor, lat, lng, tooltip) {

        // Specify features and elements to define styles.
        var styleArray = [
          { "featureType": "all", stylers: [{ saturation: -80 }] },
          { "featureType": "water", "elementType": "geometry.fill", "stylers": [{ "color": "#bae8e4" }] },
          { "featureType": "poi", "elementType": "geometry", "stylers": [{ "visibility": "off" }] },
          { "featureType": "landscape", "elementType": "geometry", "stylers": [{ "color": "#fff" }] },
          { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
          { "featureType": "administrative", "stylers": [{ "visibility": "off" }] },
          { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": roadColor }, { "saturation": "-30" }, { "lightness": "30" }] },
          { "featureType": "road", "elementType": "geometry.stroke", "stylers": [{ "color": roadColor }, { "saturation": "-30" }, { "lightness": "30" }] },
          { "featureType": "landscape", "stylers": [{ "color": landColor }] },
          { "featureType": "transit", "stylers": [{ "color": landColor }] },
          { "elementType": "labels", "stylers": [{ "visibility": "off" }] },
          { "elementType": "labels.text", "stylers": [{ "visibility": "on" }] },
          { "elementType": "labels.icon", "stylers": [{ "visibility": "on" }] }
        ];

        // Create a map object and specify the DOM element for display.
        var map = new google.maps.Map(mapEl, {
          center: {lat: lat, lng: lng},
          scrollwheel: false,
          // Apply the map style array to the map.
          styles: styleArray,
          zoom: 11
        });

        // Create a marker and set its position.
        var marker = new google.maps.Marker({
          map: map,
          position: {lat: lat, lng: lng},
          animation: google.maps.Animation.DROP,
          title: 'Our Location!'
        });

        // Marker tooltip.
        var infowindow = new google.maps.InfoWindow({
          content: tooltip
        });
        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(map,marker);
        });
        window.setTimeout(function() {
          infowindow.open(map,marker);
        }, 1000);
      }

      // Map variables
      var lat = 37.7576793;
      var lng = -122.4;
      var roadColor = "#7CFFE6";
      var landColor = "#fafafa";
      var tooltip = "123 Main Street, San Francisco, CA 94110"
      var map = $('.google-map').first();
      if (map.length) {
        initMap(map[0], roadColor, landColor, lat, lng, tooltip);
      }
    }

  });
}( jQuery ));
