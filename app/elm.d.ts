declare module "*.elm" {
    export default () => any;
}

declare module "elm-taskport" {
  export function register(functionName: string, fn: any) : void;
  export function install() : void;
}

declare module "elm-native-js/src/Native/Elements.bs" {
  import { buildHandler, addViewRender } from "elm-native-js/types/Native/Elements.bs"
  export var buildHandler;
  export var addViewRender;
}

declare module "elm-native-js/src/Native/Constants.bs" {
  import { kebabCased, view } from "elm-native-js/types/Native/Constants.bs";
  export var kebabCased;
  export var view;
}
