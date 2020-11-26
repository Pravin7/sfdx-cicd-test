public abstract class ParentClass {

    public virtual void method1(){
        System.debug('method1');
        method1_1();
        method1_2();
    }
    
    protected virtual void method1_1(){
        System.debug('method1_1');
    }

    protected virtual void method1_2(){
        System.debug('method1');
    }    
}