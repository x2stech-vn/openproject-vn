import { StreamActions, StreamElement } from '@hotwired/turbo';

export function registerDialogStreamAction() {
  StreamActions.dialog = function dialogStreamAction(this:StreamElement) {
    const content = this.templateElement.content;
    const dialog = content.querySelector('dialog') as HTMLDialogElement;

    document.body.append(content);

    // Auto-show the modal
    dialog.showModal();

    // Remove the element on close
    dialog.addEventListener('close', () => {
      if (dialog.parentElement?.tagName === 'DIALOG-HELPER') {
        dialog.parentElement.remove();
      } else {
        dialog.remove();
      }

      if (dialog.returnValue !== 'close-event-already-dispatched') {
        document.dispatchEvent(new CustomEvent('dialog:close', { detail: { dialog, submitted: false } }));
      }
    });

    // Hack to fix the width calculation of nested elements
    // such as the CKEditor toolbar.
    setTimeout(() => {
      const width = dialog.offsetWidth;
      dialog.style.width = `${width + 1}px`;
    }, 100);
  };
}
