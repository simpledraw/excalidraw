import { guestInit } from "./excalidraw-app/data/api";
import Cookies from 'js-cookie';
import { COOKIES, APP_ID } from './constants';
import { utcTs } from './time';
var seedrandom = require('seedrandom');

export class Rand {
  rng: any;
  constructor(seed:any) {
    this.rng = new seedrandom(`${seed}`);
  }
  randInt32():string {
    return `${this.rng.int32()}`;
  }
}

const newSrcValue = () => {
  const ts = utcTs();
  return `${APP_ID}_${ts}_${new Rand(ts).randInt32()}`;
}

export class User {
  public token?: string;
  public puid?: string;
  public async init() {
    // find the src locally
    let src = Cookies.get(COOKIES.src.name);
    if(!src) {
      src = newSrcValue();
      Cookies.set(COOKIES.src.name, src, {expires: COOKIES.src.expires, domain: window.location.hostname});
    }

    const { token, puid } = await guestInit(src, APP_ID);
    this.token = token;
    this.puid = puid;
  }
}
