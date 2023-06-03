/*
In NativeScript, the app.ts file is the entry point to your application.
You can use this file to perform app-level initialization, but the primary
purpose of the file is to pass control to the app’s first module.
*/

import Elm from "./src/Main.elm";
import { start } from "elm-native-js"
import { Canvas } from '@nativescript/canvas'
import * as TaskPort from 'elm-taskport';
import { kebabCased, view } from "elm-native-js/src/Native/Constants.bs"
import { buildHandler, addViewRender } from "elm-native-js/src/Native/Elements.bs"
import { Screen } from '@nativescript/core/platform'


let game: any;
TaskPort.register("initialize", (args: any) => {
  const nsCanvas = document.getElementsByTagName('ns-canvas')[0]
  if (nsCanvas == null) throw "Canvas not found"

})

const canvasAttributes = [].map(kebabCased)

const config = {
  elmModule: Elm,
  elmModuleName: "Main",
  flags: {width: Screen.mainScreen.widthPixels | 0, height: Screen.mainScreen.heightPixels | 0},
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
