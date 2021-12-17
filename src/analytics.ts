import * as _ from 'lodash';
import { logEvent } from "./excalidraw-app/data/api";

const toParams = (label: any) => label && _.isString(label) ? {label} : (label as Object) || {};
const sendEventToGTag = (category: string, name: string, label?: string | object, value?: number) => {
    window.gtag("event", name, {
      event_category: category,
      event_label: _.isString(label) ? label : JSON.stringify(label),
      value,
    });

    logEvent(name as any, {...(toParams(label)), category, value});
}
export const trackEvent =
  typeof process !== "undefined" &&
  process.env?.REACT_APP_GOOGLE_ANALYTICS_ID &&
  typeof window !== "undefined" &&
  window.gtag
    ? sendEventToGTag
    : typeof process !== "undefined" && process.env?.JEST_WORKER_ID
    ? (category: string, name: string, label?: string| object, value?: number) => {}
    : (category: string, name: string, label?: string| object, value?: number) => {
        console.info("Track Event", category, name, label, value);
        logEvent(name as any, {...(toParams(label)), category, value});
      };