import { Directive, Input } from '@angular/core';

@Directive()
export abstract class SelectableBase {
    public abstract unselect(): void;
}
