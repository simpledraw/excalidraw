import { guestInit } from "./excalidraw-app/data/api";
import Cookies from 'js-cookie';
import { APP_ID } from './constants';
import { TimeUtils, MathUtils, Constants } from '@simpledraw/common';

const newSrcValue = () => {
  const ts = TimeUtils.utcTs();
  return `${APP_ID}_${ts}_${new MathUtils.Rand(ts).randInt32()}`;
}

export class User {
  public token?: string;
  public puid?: string;
  public isReady?: boolean;
  public lastError?: {message: string};
  public async init() {
    this.isReady = false;
    // find the src locally
    let src = Cookies.get(Constants.COOKIES.src.name);
    if(!src) {
      src = newSrcValue();
      Cookies.set(Constants.COOKIES.src.name, src, {expires: Constants.COOKIES.src.expires, domain: window.location.hostname});
    }

    try{
      const { token, puid } = await guestInit(src, APP_ID);
      this.token = token;
      this.puid = puid;
    }catch(err){
      this.lastError = {message: (err as any).message};
    }
  }
}
