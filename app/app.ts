/*
In NativeScript, the app.ts file is the entry point to your application.
You can use this file to perform app-level initialization, but the primary
purpose of the file is to pass control to the app’s first module.
*/

import Elm from "./src/Main.elm";
import { start } from "elm-native-js"
import { Canvas } from '@nativescript/canvas'
import * as TNSPhaser from "@nativescript/canvas-phaser";
import * as TaskPort from 'elm-taskport';
import { kebabCased, view } from "elm-native-js/src/Native/Constants.bs"
import { buildHandler, addViewRender } from "elm-native-js/src/Native/Elements.bs"

let game: any;
TaskPort.register("initialize", (args: any) => {
  game = TNSPhaser.Game(args)
})

const canvasAttributes = [].map(kebabCased)

const config = {
  elmModule: Elm,
  elmModuleName: "Main",
  customElements: [
    { tagName: 'ns-canvas'
    , handler: buildHandler(
      () => new Canvas(),
        view.concat(canvasAttributes),
        addViewRender
      )
    }
  ]
}

start(config)

/*
Do not place any code after the application has been started as it will not
be executed on iOS.
*/
