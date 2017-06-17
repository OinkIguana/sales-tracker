export interface Wait<T> extends Promise<T> {
  cancel(): void;
  reset(): void;
  skip(): void;
}
type ResRej<T> = (value?: T | PromiseLike<T>) => void;
export default <T>(time: number, cb: (resolve: ResRej<T>, reject: ResRej<T>) => T | PromiseLike<T>) => {
  let timeout: number;
  let res: ResRej<T>;
  let rej: ResRej<T>;
  const pr = new Promise<T>((resolve, reject) => {
    timeout = setTimeout(() => cb(resolve, reject), time);
    res = resolve;
    rej = reject;
  }) as Wait<T>;
  pr.cancel = () => {
    clearTimeout(timeout);
    rej();
    return pr;
  };
  pr.skip = () => {
    clearTimeout(timeout);
    cb(res, rej);
    return pr;
  };
  pr.reset = () => {
    clearTimeout(timeout);
    timeout = setTimeout(() => cb(res, rej), time);
    return pr;
  };
  return pr;
};
