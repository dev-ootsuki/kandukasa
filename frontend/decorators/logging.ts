type Method = (...args: any[]) => any
type Context = {
    kind: string
    name: string | symbol
    access: {
        get?(): unknown
        set?(value: unknown): void
        has?(value: unknown): boolean
    }
    private?: boolean
    static?: boolean
    addInitializer?(initializer: () => void): void
}

const _logged = (name: string, ret : any | undefined, ...args : any[]) => {
}
function logging<This, Args extends any[], Return>(
                    target: (this: This, ...args: Args) => Return,
                    { name }: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>
    ){
    const methodName = String(name);
    return function(this: This, ...args: Args): Return {
      console.time(methodName);
      try {
        return target.call(this, ...args);
      } finally {
        console.timeLog(methodName);
      }
    };
  }