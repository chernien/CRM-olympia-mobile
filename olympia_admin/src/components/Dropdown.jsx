import React, { useState, useRef, useEffect } from 'react';

const Dropdown = ({ trigger, children, position = 'right' }) => {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative inline-block" ref={dropdownRef}>
      <div className="cursor-pointer flex items-center" onClick={() => setIsOpen(!isOpen)}>
        {trigger}
      </div>
      {isOpen && (
        <div className={`
          absolute top-[calc(100%+12px)] bg-white min-width-[200px] rounded-subtle shadow-premium p-2 z-[1000] border border-slate-100 
          animate-in fade-in slide-in-from-top-2 duration-200
          ${position === 'right' ? 'right-0' : 'left-0'}
        `}>
          {children}
        </div>
      )}
    </div>
  );
};

export default Dropdown;
