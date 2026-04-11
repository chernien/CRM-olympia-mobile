import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { Calendar as CalendarIcon, ChevronLeft, ChevronRight, X } from 'lucide-react';

const DatePicker = ({ value, onChange, placeholder = 'Choisir une date', className = "" }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [currentDate, setCurrentDate] = useState(value ? new Date(value) : new Date());
  const [coords, setCoords] = useState({ top: 0, left: 0, width: 0, placement: 'bottom' });
  const triggerRef = useRef(null);
  const dropdownRef = useRef(null);

  const updatePosition = () => {
    if (triggerRef.current) {
      const rect = triggerRef.current.getBoundingClientRect();
      const dropdownHeight = 400; // Estimated max height for calendar
      const spaceBelow = window.innerHeight - rect.bottom;
      const placement = spaceBelow < dropdownHeight && rect.top > dropdownHeight ? 'top' : 'bottom';
      
      let leftOffset = rect.left;
      if (leftOffset + 320 > window.innerWidth - 16) {
        leftOffset = window.innerWidth - 336;
      }
      
      setCoords({
        top: placement === 'bottom' ? rect.bottom + 8 : rect.top - 8,
        left: Math.max(16, leftOffset),
        width: rect.width,
        placement
      });
    }
  };

  useEffect(() => {
    if (isOpen) {
      window.addEventListener('scroll', updatePosition, true);
      window.addEventListener('resize', updatePosition);
    }
    return () => {
      window.removeEventListener('scroll', updatePosition, true);
      window.removeEventListener('resize', updatePosition);
    };
  }, [isOpen]);

  const handleToggle = () => {
    if (!isOpen) updatePosition();
    setIsOpen(!isOpen);
  };

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target) && 
          triggerRef.current && !triggerRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);

  const daysInMonth = (year, month) => new Date(year, month + 1, 0).getDate();
  const firstDayOfMonth = (year, month) => new Date(year, month, 1).getDay();

  const handlePrevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const handleNextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const handleDateSelect = (day) => {
    const selectedDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), day);
    onChange(selectedDate.toISOString().split('T')[0]);
    setIsOpen(false);
  };

  const renderDays = () => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const totalDays = daysInMonth(year, month);
    const startDay = firstDayOfMonth(year, month);
    const days = [];

    for (let i = 0; i < startDay; i++) {
      days.push(<div key={`empty-${i}`} className="h-10 w-10"></div>);
    }

    const today = new Date().toISOString().split('T')[0];
    const selected = value;

    for (let d = 1; d <= totalDays; d++) {
      const dateStr = new Date(year, month, d).toISOString().split('T')[0];
      const isToday = dateStr === today;
      const isSelected = dateStr === selected;

      days.push(
        <div 
          key={d}
          onClick={() => handleDateSelect(d)}
          className={`
            h-10 w-10 flex items-center justify-center rounded-lg cursor-pointer text-sm font-bold transition-all
            ${isSelected ? 'bg-primary text-white shadow-md shadow-primary/30' : 
              isToday ? 'bg-primary/10 text-primary border border-primary/20' : 
              'text-text-primary hover:bg-slate-50'
            }
          `}
        >
          {d}
        </div>
      );
    }
    return days;
  };

  const monthNames = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  const formatDate = (dateStr) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' });
  };

  const calendarDropdown = (
    <div 
      ref={dropdownRef}
      style={{ 
        position: 'fixed', 
        top: coords.placement === 'bottom' ? `${coords.top}px` : 'auto',
        bottom: coords.placement === 'top' ? `${window.innerHeight - coords.top}px` : 'auto',
        left: `${coords.left}px`,
        width: '320px'
      }}
      className={`
        bg-white rounded-premium shadow-premium border border-slate-100 z-[9999] p-4 
        animate-in fade-in 
        ${coords.placement === 'bottom' ? 'slide-in-from-top-2' : 'slide-in-from-bottom-2'} 
        duration-200
      `}
    >
      <div className="flex items-center justify-between mb-6">
        <button 
          type="button"
          onClick={handlePrevMonth} 
          className="p-2 hover:bg-slate-50 rounded-lg text-text-secondary transition-colors"
        >
          <ChevronLeft size={20} />
        </button>
        <span className="text-sm font-black text-text-primary uppercase tracking-widest">
          {monthNames[currentDate.getMonth()]} {currentDate.getFullYear()}
        </span>
        <button 
          type="button"
          onClick={handleNextMonth} 
          className="p-2 hover:bg-slate-50 rounded-lg text-text-secondary transition-colors"
        >
          <ChevronRight size={20} />
        </button>
      </div>

      <div className="grid grid-cols-7 gap-1 mb-2">
        {['D', 'L', 'M', 'M', 'J', 'V', 'S'].map((day, ix) => (
          <div key={ix} className="h-10 w-10 flex items-center justify-center text-[10px] font-black text-text-secondary uppercase">
            {day}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-7 gap-1">
        {renderDays()}
      </div>

      <div className="mt-6 pt-4 border-t border-slate-50 flex justify-end">
        <button 
          type="button"
          onClick={() => {
            const today = new Date().toISOString().split('T')[0];
            onChange(today);
            setIsOpen(false);
          }}
          className="text-[10px] font-black text-primary uppercase tracking-widest hover:underline"
        >
          Aujourd'hui
        </button>
      </div>
    </div>
  );

  return (
    <div className={`relative ${className}`}>
      <div 
        ref={triggerRef}
        onClick={handleToggle}
        className={`
          flex items-center justify-between p-4 bg-slate-50 border rounded-xl cursor-pointer transition-all duration-200
          ${isOpen ? 'border-primary/50 bg-white shadow-sm ring-2 ring-primary/5' : 'border-slate-100 hover:border-slate-200 hover:bg-slate-100/50'}
        `}
      >
        <div className="flex items-center gap-3 overflow-hidden">
          <CalendarIcon size={18} className="text-text-secondary shrink-0" />
          {value ? (
            <span className="text-text-primary font-medium truncate">{formatDate(value)}</span>
          ) : (
            <span className="text-text-secondary font-medium truncate">{placeholder}</span>
          )}
        </div>
      </div>

      {isOpen && createPortal(calendarDropdown, document.body)}
    </div>
  );
};

export default DatePicker;
