import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { ChevronDown, Search, Check, X } from 'lucide-react';

const Select = ({ 
  options = [], 
  value, 
  onChange, 
  placeholder = 'Sélectionner...', 
  searchable = true,
  icon: Icon,
  className = ""
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [coords, setCoords] = useState({ top: 0, left: 0, width: 0, placement: 'bottom' });
  const triggerRef = useRef(null);
  const dropdownRef = useRef(null);

  const selectedOption = options.find(opt => opt.value === value);

  const updatePosition = () => {
    if (triggerRef.current) {
      const rect = triggerRef.current.getBoundingClientRect();
      const dropdownHeight = 320; // Max estimated height
      const spaceBelow = window.innerHeight - rect.bottom;
      const placement = spaceBelow < dropdownHeight && rect.top > dropdownHeight ? 'top' : 'bottom';
      
      const assumedWidth = Math.max(rect.width, 200);
      let leftOffset = rect.left;
      if (leftOffset + assumedWidth > window.innerWidth - 16) {
        leftOffset = window.innerWidth - assumedWidth - 16;
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

  const filteredOptions = options.filter(opt => 
    opt.label.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSelect = (val) => {
    onChange(val);
    setIsOpen(false);
    setSearchTerm('');
  };

  const selectDropdown = (
    <div 
      ref={dropdownRef}
      style={{ 
        position: 'fixed', 
        top: coords.placement === 'bottom' ? `${coords.top}px` : 'auto',
        bottom: coords.placement === 'top' ? `${window.innerHeight - coords.top}px` : 'auto',
        left: `${coords.left}px`,
        width: `${coords.width}px`,
        minWidth: '200px'
      }}
      className={`
        bg-white rounded-xl shadow-premium border border-slate-100 z-[9999] overflow-hidden 
        animate-in fade-in 
        ${coords.placement === 'bottom' ? 'slide-in-from-top-2' : 'slide-in-from-bottom-2'} 
        duration-200
      `}
    >
      {searchable && (
        <div className="p-3 border-b border-slate-50 relative">
          <Search size={14} className="absolute left-6 top-1/2 -translate-y-1/2 text-text-secondary" />
          <input 
            autoFocus
            type="text" 
            placeholder="Rechercher..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-100 rounded-lg outline-none focus:border-primary/30 text-xs font-medium"
            onClick={(e) => e.stopPropagation()}
          />
        </div>
      )}
      
      <div className="max-h-[240px] overflow-y-auto p-1 custom-scrollbar">
        {filteredOptions.length > 0 ? (
          filteredOptions.map((opt) => (
            <div 
              key={opt.value}
              onClick={() => handleSelect(opt.value)}
              className={`
                flex items-center justify-between px-4 py-3 rounded-lg cursor-pointer transition-colors group
                ${value === opt.value ? 'bg-primary/5 text-primary' : 'hover:bg-slate-50 text-text-primary'}
              `}
            >
              <div className="flex items-center gap-3 overflow-hidden">
                {opt.icon && <opt.icon size={16} className={value === opt.value ? 'text-primary' : 'text-text-secondary group-hover:text-primary transition-colors'} />}
                <span className="text-sm font-semibold truncate">{opt.label}</span>
              </div>
              {value === opt.value && <Check size={16} className="shrink-0" />}
            </div>
          ))
        ) : (
          <div className="p-8 text-center">
            <p className="text-xs text-text-secondary font-bold uppercase tracking-widest">Aucun résultat</p>
          </div>
        )}
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
          {Icon && <Icon size={18} className="text-text-secondary shrink-0" />}
          {selectedOption ? (
            <span className="text-text-primary font-medium truncate">{selectedOption.label}</span>
          ) : (
            <span className="text-text-secondary font-medium truncate">{placeholder}</span>
          )}
        </div>
        <ChevronDown 
          size={18} 
          className={`text-text-secondary transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`} 
        />
      </div>

      {isOpen && createPortal(selectDropdown, document.body)}
    </div>
  );
};

export default Select;
