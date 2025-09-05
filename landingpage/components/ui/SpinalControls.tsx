'use client';

import React from 'react';

interface SpinalControlsProps {
  language: 'ko' | 'en';
  severity: number;
  curveType: 'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined';
  onSeverityChange: (value: number) => void;
  onCurveTypeChange: (type: 'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined') => void;
}

const SpinalControls: React.FC<SpinalControlsProps> = ({
  language,
  severity,
  curveType,
  onSeverityChange,
  onCurveTypeChange
}) => {
  const handleSliderChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onSeverityChange(parseInt(e.target.value));
  };

  const handleTypeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onCurveTypeChange(e.target.value as any);
  };

  return (
    <div className="bg-primary-600 text-white rounded-2xl px-4 py-3 flex items-center gap-3 shadow-lg justify-center flex-wrap text-sm max-w-lg mx-auto">
      {/* Curve type selector */}
      <span className="font-bold">
        {language === 'ko' ? '유형' : 'Type'}
      </span>
      <select
        value={curveType}
        onChange={handleTypeChange}
        className="border-none rounded-xl px-3 py-1.5 font-bold text-gray-800 bg-white text-sm min-w-[140px]"
      >
        <option value="combined">{language === 'ko' ? 'S자형 (이중)' : 'Double Major (S)'}</option>
        <option value="healthy">{language === 'ko' ? '정상' : 'Healthy'}</option>
        <option value="thoracic">{language === 'ko' ? '흉추' : 'Thoracic'}</option>
        <option value="lumbar">{language === 'ko' ? '요추' : 'Lumbar'}</option>
        <option value="thoracolumbar">{language === 'ko' ? '흉요추' : 'Thoraco-Lumbar'}</option>
      </select>
      
      {/* Severity label */}
      <span className="font-bold">
        {language === 'ko' ? '심각도' : 'Severity'}
      </span>
      
      {/* Range slider */}
      <div className="relative flex items-center">
        <input
          type="range"
          min="0"
          max="60"
          value={severity}
          onChange={handleSliderChange}
          disabled={curveType === 'healthy'}
          className={`w-[180px] h-2 bg-white/50 rounded-full outline-none ${
            curveType === 'healthy' ? 'cursor-not-allowed opacity-50' : 'cursor-pointer'
          }`}
          style={{
            background: curveType === 'healthy' 
              ? 'rgba(255,255,255,0.3)' 
              : `linear-gradient(to right, #ffffff 0%, #ffffff ${(severity/60)*100}%, rgba(255,255,255,0.5) ${(severity/60)*100}%, rgba(255,255,255,0.5) 100%)`,
            WebkitAppearance: 'none',
            appearance: 'none'
          }}
        />
      </div>
      
      {/* Degree display */}
      {/* <div className="bg-white text-gray-800 rounded-full px-3 py-1.5 font-bold text-sm min-w-[50px] text-center">
        {curveType === 'healthy' ? '0' : severity}°
      </div> */}
    </div>
  );
};

export default SpinalControls;