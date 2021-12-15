import moment from 'moment';

export const utcUnix = () => moment.utc().unix();
export const utcTs = () => moment.utc().valueOf();
export const utcTomorrow = () => moment.utc().endOf('day').valueOf();
export const utcTomorrowUnix = () => moment.utc().endOf('day').unix();
export const readableIntervalUnix = (diff: number) => {
  const sec = Math.floor(diff);
  if(sec < 60) {
    return `${sec} seconds`
  }
  const min = Math.floor(sec / 60);
  if(min < 60) {
    return `${min} minutes`
  }
  const hour = Math.floor(min/60);
  if(hour < 24) {
    return `${hour} hours`
  }
  const days = Math.floor(hour/24);
  if(days < 30) {
    return `${days} days`
  }
  const month = Math.floor(days/24);

  return `${month} months`
}
export const readableInterval = (diffTs: number) => {
  return readableIntervalUnix(diffTs/1000);
}
// 2030-01-01
const ONE_DAY = 24 * 60 * 60;
const ONE_YEAR = ONE_DAY * 365;
export const utcForever = () => moment('2030-01-01').utc().unix();
