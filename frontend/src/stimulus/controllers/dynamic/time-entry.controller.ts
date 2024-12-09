/*
 * -- copyright
 * OpenProject is an open source project management software.
 * Copyright (C) the OpenProject GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version 3.
 *
 * OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
 * Copyright (C) 2006-2013 Jean-Philippe Lang
 * Copyright (C) 2010-2013 the ChiliProject Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * See COPYRIGHT and LICENSE files for more details.
 * ++
 */

import { Controller } from '@hotwired/stimulus';
import { parseChronicDuration, outputChronicDuration } from 'core-app/shared/helpers/chronic_duration';
import flatpickr from 'flatpickr';

interface HTMLInputElementWithFlatpickr extends HTMLInputElement {
  _flatpickr?:flatpickr.Instance;
}

export default class TimeEntryController extends Controller {
  static targets = ['startTimeInput', 'endTimeInput', 'hoursInput'];

  declare readonly startTimeInputTarget:HTMLInputElementWithFlatpickr;
  declare readonly endTimeInputTarget:HTMLInputElementWithFlatpickr;
  declare readonly hoursInputTarget:HTMLInputElement;

  startTimeInputTargetConnected() {
    this.initTimePicker(this.startTimeInputTarget);
  }

  endTimeInputTargetConnected() {
    this.initTimePicker(this.endTimeInputTarget);
  }

  datesChanged(initiatedBy:HTMLInputElement) {
    const startTimeParts = this.startTimeInputTarget.value.split(':');
    const endTimeParts = this.endTimeInputTarget.value.split(':');

    const startTimeInMinutes = parseInt(startTimeParts[0], 10) * 60 + parseInt(startTimeParts[1], 10);
    const endTimeInMinutes = parseInt(endTimeParts[0], 10) * 60 + parseInt(endTimeParts[1], 10);
    const hoursInMinutes = Math.round((parseChronicDuration(this.hoursInputTarget.value) || 0) / 60);

    // We calculate the hours field if:
    //  - We have start & end time and no hours
    //  - We have start & end time and we have triggered the change from the end time field
    if (startTimeInMinutes && endTimeInMinutes && (hoursInMinutes === 0 || initiatedBy === this.endTimeInputTarget)) {
      const duration = endTimeInMinutes - startTimeInMinutes;
      this.hoursInputTarget.value = outputChronicDuration(duration * 60, { format: 'hours_only' }) || '';
    } else if (startTimeInMinutes && hoursInMinutes) {
      const newEndTime = startTimeInMinutes + hoursInMinutes;

      const targetDate = new Date();
      targetDate.setHours(Math.floor(newEndTime / 60));
      targetDate.setMinutes(Math.round(newEndTime % 60));
      targetDate.setSeconds(0);
      this.endTimeInputTarget._flatpickr!.setDate(targetDate); // eslint-disable-line no-underscore-dangle
    }

    this.toggleEndTimePlusCaption(startTimeInMinutes + hoursInMinutes);
  }

  hoursChanged() {
    // Parse input through our chronic duration parser and then reformat as hours that can be nicely parsed on the
    // backend
    const hours = parseChronicDuration(this.hoursInputTarget.value, { defaultUnit: 'hours', ignoreSecondsWhenColonSeperated: true });
    this.hoursInputTarget.value = outputChronicDuration(hours, { format: 'hours_only' }) || '';

    this.datesChanged(this.hoursInputTarget);
  }

  hoursKeyEnterPress(event:KeyboardEvent) {
    if (event.currentTarget instanceof HTMLInputElement) {
      event.currentTarget.blur();
    }
  }

  toggleEndTimePlusCaption(endTimeInMinutes:number) {
    const formControl = this.endTimeInputTarget.closest('.FormControl') as HTMLElement;
    formControl.querySelectorAll('.FormControl-caption').forEach((caption) => caption.remove());

    if (endTimeInMinutes > (24 * 60)) {
      const diffInDays = Math.floor(endTimeInMinutes / (60 * 24));
      const span = document.createElement('span');
      span.className = 'FormControl-caption';
      span.innerText = `+ ${diffInDays} ${diffInDays === 1 ? 'day' : 'days'}`;
      formControl.append(span);
    }
  }

  initTimePicker(field:HTMLInputElement) {
    flatpickr(field, {
      enableTime: true,
      noCalendar: true,
      dateFormat: 'H:i',
      time_24hr: true,
      static: true,
      appendTo: document.querySelector('#time-entry-dialog') as HTMLElement,
      onChange: () => {
        this.datesChanged(field);
      },
    });
  }
}
