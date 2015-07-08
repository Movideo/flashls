/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
 package org.mangui.osmf.plugins.traits {

    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.events.Event;
    
    import org.mangui.hls.HLS;
    import org.osmf.media.videoClasses.VideoSurface;
    import org.osmf.traits.DisplayObjectTrait;
    
    CONFIG::LOGGING {
    import org.mangui.hls.utils.Log;
    }

    public class HLSDisplayObjectTrait extends DisplayObjectTrait
    {
        private static var _force:Boolean;

        private var videoSurface : VideoSurface;
        private var _hls : HLS;

        public function HLSDisplayObjectTrait(hls : HLS, videoSurface : DisplayObject, mediaWidth : int = 0, mediaHeight : int = 0)
        {
            CONFIG::LOGGING { Log.info("HLSDisplayObjectTrait()"); }

            _hls = hls;
            super(videoSurface, mediaWidth, mediaHeight);
            this.videoSurface = videoSurface as VideoSurface;

            if (this.videoSurface is VideoSurface)
            {
                this.videoSurface.addEventListener(Event.ADDED_TO_STAGE, onStage);
                this.videoSurface.addEventListener(Event.REMOVED_FROM_STAGE, onStageRemoved);
            }
        }

        override public function dispose() : void
        {
            CONFIG::LOGGING { Log.info("HLSDisplayObjectTrait:dispose " + _force); }

            videoSurface.removeEventListener(Event.ENTER_FRAME, onFrame);
            super.dispose();
        }

        private function onStage(event:Event) : void
        {
            trace('>>> HLS:: added to stage');
            CONFIG::LOGGING { Log.info("HLSDisplayObjectTrait:addedToStage " + _force); }

            _hls.stage = event.target.stage as Stage;
            videoSurface.removeEventListener(Event.ADDED_TO_STAGE, onStage);
            videoSurface.addEventListener(Event.ENTER_FRAME, onFrame);

            // force a resize immediate
            _force = true;

            onFrame();
        }

        private function onStageRemoved(event:Event):void
        {
            trace('>>> HLS:: removed from stage');
            CONFIG::LOGGING { Log.info("HLSDisplayObjectTrait:removedFromStage " + _force); }

            _hls.stage = null;
            dispose();

            // wait for it to be added again
            videoSurface.addEventListener(Event.ADDED_TO_STAGE, onStage);
        }

        private var _force:Boolean;

        private function onFrame(event:Event = null) : void
        {
//            CONFIG::LOGGING { Log.info("frame " + _force); }
            var newWidth : int = videoSurface.videoWidth;
            var newHeight : int = videoSurface.videoHeight;
            if (newWidth != 0 && newHeight != 0 && (newWidth != mediaWidth || newHeight != mediaHeight)) {
                // If there is no layout, set as no scale.
                if (videoSurface.width == 0 && videoSurface.height == 0) {
                    videoSurface.width = newWidth;
                    videoSurface.height = newHeight;
                }
                CONFIG::LOGGING {
                Log.info("HLSDisplayObjectTrait:setMediaSize(" + newWidth + "," + newHeight + ")");
                }
                setMediaSize(newWidth, newHeight);
            }
            // videoSurface.removeEventListener(Event.ENTER_FRAME, onFrame);
        }
    }
}